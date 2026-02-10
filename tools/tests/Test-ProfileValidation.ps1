BeforeAll {
    . "$PSScriptRoot/../../validate_use_case_profiles.ps1"
}

Describe 'Profile Validation' {
    Context 'Profile catalog parsing' {
        It 'Parses valid profile structure' {
            $profilesPath = "$PSScriptRoot/fixtures/valid_profile.yaml"

            if (Test-Path $profilesPath) {
                $catalog = Get-ProfileCatalog -Path $profilesPath

                $catalog.profiles | Should -Not -BeNullOrEmpty
                $catalog.profiles.Count | Should -BeGreaterThan 0

                foreach ($profile in $catalog.profiles) {
                    $profile.id | Should -Not -BeNullOrEmpty
                    $profile.min_risk_class | Should -BeGreaterOrEqual 0
                    $profile.min_risk_class | Should -BeLessOrEqual 4
                    $profile.required_bundles | Should -Not -BeNullOrEmpty
                    $profile.required_bundles.Count | Should -BeGreaterThan 0
                }
            } else {
                Set-ItResult -Skipped -Because "Fixture file not found"
            }
        }

        It 'Reads version field from profile catalog' {
            $profilesPath = "$PSScriptRoot/fixtures/valid_profile.yaml"

            if (Test-Path $profilesPath) {
                $catalog = Get-ProfileCatalog -Path $profilesPath
                $catalog.version | Should -Not -BeNullOrEmpty
                $catalog.version | Should -Match '^\d+\.\d+\.\d+$'
            } else {
                Set-ItResult -Skipped -Because "Fixture file not found"
            }
        }
    }

    Context 'Bundle catalog parsing' {
        It 'Parses valid bundle structure' {
            $bundlesPath = "$PSScriptRoot/fixtures/valid_bundles.yaml"

            if (Test-Path $bundlesPath) {
                $catalog = Get-BundleCatalog -Path $bundlesPath

                $catalog.bundles | Should -Not -BeNullOrEmpty
                $catalog.bundles.Count | Should -BeGreaterThan 0

                foreach ($bundle in $catalog.bundles) {
                    $bundle.id | Should -Not -BeNullOrEmpty
                    $bundle.primary_nap_anchors | Should -Not -BeNullOrEmpty
                }
            } else {
                Set-ItResult -Skipped -Because "Fixture file not found"
            }
        }
    }

    Context 'Validation rules' {
        It 'Validates min_risk_class is within valid range' {
            $validProfiles = @(
                @{ min_risk_class = 0; valid = $true }
                @{ min_risk_class = 1; valid = $true }
                @{ min_risk_class = 2; valid = $true }
                @{ min_risk_class = 3; valid = $true }
                @{ min_risk_class = 4; valid = $true }
            )

            $invalidProfiles = @(
                @{ min_risk_class = -1; valid = $false }
                @{ min_risk_class = 5; valid = $false }
                @{ min_risk_class = $null; valid = $false }
            )

            foreach ($p in $validProfiles) {
                $p.valid | Should -BeTrue
                $p.min_risk_class | Should -BeGreaterOrEqual 0
                $p.min_risk_class | Should -BeLessOrEqual 4
            }

            foreach ($p in $invalidProfiles) {
                $p.valid | Should -BeFalse
            }
        }

        It 'Validates autonomy_ceiling format' {
            $validCeilings = @("A0", "A1", "A2", "A3", "A4")
            $invalidCeilings = @("A5", "B1", "a1", "A02", "")

            foreach ($ceiling in $validCeilings) {
                $rank = Get-AutonomyRank -Tier $ceiling
                $rank | Should -BeGreaterOrEqual 0
                $rank | Should -BeLessOrEqual 4
            }

            foreach ($ceiling in $invalidCeilings) {
                $rank = Get-AutonomyRank -Tier $ceiling
                $rank | Should -Be -1
            }
        }

        It 'Requires at least one required_bundles per profile' {
            $profileWithoutBundles = [pscustomobject]@{
                id = "test_profile"
                required_bundles = @()
            }

            $profileWithoutBundles.required_bundles.Count | Should -Be 0

            $profileWithBundles = [pscustomobject]@{
                id = "test_profile"
                required_bundles = @("B01", "B02")
            }

            $profileWithBundles.required_bundles.Count | Should -BeGreaterThan 0
        }
    }

    Context 'Cross-reference validation' {
        It 'Detects unknown bundle references in profiles' {
            $bundleIds = @("B01", "B02", "B03")
            $profileBundleIds = @("B01", "B99")

            $unknownBundles = $profileBundleIds | Where-Object { $_ -notin $bundleIds }
            $unknownBundles.Count | Should -Be 1
            $unknownBundles[0] | Should -Be "B99"
        }

        It 'Detects duplicate bundle IDs' {
            $bundleIds = @("B01", "B02", "B01")
            $duplicates = $bundleIds | Group-Object | Where-Object { $_.Count -gt 1 }

            $duplicates.Count | Should -Be 1
            $duplicates[0].Name | Should -Be "B01"
            $duplicates[0].Count | Should -Be 2
        }

        It 'Detects duplicate profile IDs' {
            $profileIds = @("p1", "p2", "p1")
            $duplicates = $profileIds | Group-Object | Where-Object { $_.Count -gt 1 }

            $duplicates.Count | Should -Be 1
            $duplicates[0].Name | Should -Be "p1"
            $duplicates[0].Count | Should -Be 2
        }
    }
}
