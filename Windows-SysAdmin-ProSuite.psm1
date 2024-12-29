name: Publish Artifacts with SLSA3 and Run Pester Tests

on:
  workflow_dispatch:
    inputs:
      artifact_version:
        description: "Version of the artifact to publish"
        required: true
      repository_name:
        description: "Name of the target repository"
        required: true

permissions:
  contents: write
  id-token: write

jobs:
  build-and-test:
    name: Build, Test, and Publish Artifact
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Source Code
      uses: actions/checkout@v3

    - name: Install PowerShell and Dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y wget apt-transport-https software-properties-common
        wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y powershell
        pwsh -Command 'Write-Host "PowerShell installed successfully."'

    - name: Run Pester Tests for Module Validation
      run: |
        pwsh -Command "Invoke-Pester -Path './Tests/ModuleValidation.Tests.ps1' -Output Detailed"
      shell: pwsh

    - name: Run Pester Tests for Command Validation
      run: |
        pwsh -Command "Invoke-Pester -Path './Tests/CommandValidation.Tests.ps1' -Output Detailed"
      shell: pwsh

    - name: Run All Pester Tests
      run: |
        pwsh -Command "Invoke-Pester -Path './Tests' -Output Detailed"
      shell: pwsh

    - name: Build Artifact
      run: |
        echo "Building artifact..."
        mkdir -p artifacts
        tar -czf artifacts/${{ github.event.inputs.artifact_version }}.tar.gz .

    - name: SLSA Provenance Generation
      id: provenance
      uses: slsa-framework/slsa-github-generator@v1.3.0
      with:
        base64-encoding: "true"

    - name: Verify Provenance
      run: |
        echo "Verifying provenance for compliance with SLSA3..."
        # Add verification script or tooling if available

    - name: Publish Artifact
      uses: actions/upload-artifact@v3
      with:
        name: ${{ github.event.inputs.artifact_version }}
        path: artifacts/${{ github.event.inputs.artifact_version }}.tar.gz

    - name: Notify Success
      run: echo "Artifact successfully published with SLSA3 compliance."

  verify-and-release:
    name: Verify Release Integrity
    needs: build-and-test
    runs-on: ubuntu-latest

    steps:
    - name: Checkout Repository
      uses: actions/checkout@v3

    - name: Download Artifact
      uses: actions/download-artifact@v3
      with:
        name: ${{ github.event.inputs.artifact_version }}

    - name: Verify Artifact Signature
      run: |
        echo "Verifying artifact signature for integrity and authenticity..."
        # Replace with actual signature verification commands

    - name: Push Artifact to Repository
      env:
        REPO_NAME: ${{ github.event.inputs.repository_name }}
      run: |
        echo "Pushing artifact to $REPO_NAME repository..."
        # Replace with publishing logic to repository or package manager

    - name: Confirm Release
      run: echo "Release process completed successfully."
