<#
.SYNOPSIS
    .
.DESCRIPTION
    add a description here
.PARAMETER Path
    The path to the .
.PARAMETER LiteralPath
    Specifies a path to one or more locations. Unlike Path, the value of 
    LiteralPath is used exactly as it is typed. No characters are interpreted 
    as wildcards. If the path includes escape characters, enclose it in single
    quotation marks. Single quotation marks tell Windows PowerShell not to 
    interpret any characters as escape sequences.
#>

Param(
    [String]$Targets = "Help" ,  #The targets to run.
    [String]$app_name = "myApp"
)