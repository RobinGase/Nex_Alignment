BeforeAll {
    . "$PSScriptRoot/../../validate_use_case_profiles.ps1"
}

Describe 'Get-AutonomyRank' {
    Context 'Valid autonomy tiers' {
        It 'Returns 0 for A0' {
            Get-AutonomyRank -Tier "A0" | Should -Be 0
        }

        It 'Returns 1 for A1' {
            Get-AutonomyRank -Tier "A1" | Should -Be 1
        }

        It 'Returns 2 for A2' {
            Get-AutonomyRank -Tier "A2" | Should -Be 2
        }

        It 'Returns 3 for A3' {
            Get-AutonomyRank -Tier "A3" | Should -Be 3
        }

        It 'Returns 4 for A4' {
            Get-AutonomyRank -Tier "A4" | Should -Be 4
        }
    }

    Context 'Invalid autonomy tiers' {
        It 'Returns -1 for null tier' {
            Get-AutonomyRank -Tier $null | Should -Be -1
        }

        It 'Returns -1 for empty string' {
            Get-AutonomyRank -Tier "" | Should -Be -1
        }

        It 'Returns -1 for invalid tier format' {
            Get-AutonomyRank -Tier "B1" | Should -Be -1
        }

        It 'Returns -1 for tier out of range' {
            Get-AutonomyRank -Tier "A5" | Should -Be -1
        }

        It 'Returns -1 for case-sensitive mismatch' {
            Get-AutonomyRank -Tier "a1" | Should -Be -1
            Get-AutonomyRank -Tier "A02" | Should -Be -1
        }
    }

    Context 'Case sensitivity' {
        It 'Enforces exact case matching' {
            Get-AutonomyRank -Tier "a0" | Should -Not -Be 0
            Get-AutonomyRank -Tier "A0" | Should -Be 0
        }
    }
}
