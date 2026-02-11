BeforeAll {
    . "$PSScriptRoot/../validate_use_case_profiles.ps1"
}

Describe 'Get-ListFromBlock' {
    Context 'Valid list extraction' {
        It 'Extracts single-item list correctly' {
            $block = @'
key:
  - item1
something-else: value
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 1
            $result[0] | Should -Be "item1"
        }

        It 'Extracts multi-item list correctly' {
            $block = @'
key:
  - item1
  - item2
  - item3
something-else: value
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 3
            $result[0] | Should -Be "item1"
            $result[1] | Should -Be "item2"
            $result[2] | Should -Be "item3"
        }
    }

    Context 'Whitespace and special characters' {
        It 'Trims whitespace from items' {
            $block = @'
key:
  -  item with spaces  
  - item2
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result[0] | Should -Be "item with spaces"
            $result[1] | Should -Be "item2"
        }

        It 'Handles items with hyphens and underscores' {
            $block = @'
key:
  - item-with-hyphens
  - item_with_underscores
  - item-123_456
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 3
            $result[0] | Should -Be "item-with-hyphens"
            $result[1] | Should -Be "item_with_underscores"
            $result[2] | Should -Be "item-123_456"
        }
    }

    Context 'Empty and edge cases' {
        It 'Returns empty array when key not found' {
            $block = @'
other-key:
  - item1
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 0
        }

        It 'Returns empty array for empty list' {
            $block = @'
key:
other-key: value
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 0
        }

        It 'Stops at next key definition' {
            $block = @'
key:
  - item1
next-key:
  - should-not-be-included
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 1
            $result[0] | Should -Be "item1"
        }
    }

    Context 'Multi-line values' {
        It 'Handles items with quotes containing spaces' {
            $block = @'
key:
  - "quoted with spaces"
  - unquoted_item
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 2
        }

        It 'Handles items with special characters' {
            $block = @'
key:
  - item@domain.com
  - /path/to/file
  - env:VAR=value
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 3
        }
    }

    Context 'Unicode handling' {
        It 'Handles UTF-8 characters in items' {
            $block = @'
key:
  - item-日本語
  - item-中文
  - item-العربية
'@
            $result = Get-ListFromBlock -Block $block -Key "key"
            $result.Count | Should -Be 3
        }
    }
}
