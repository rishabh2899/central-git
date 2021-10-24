# Getting input from terminal
# $filename = $args[0]  # Read-Host("Enter filename: ")
# $dbs = $args[1]       #Read-Host("Enter dbs: ")
# $extname =$args[2]    #Read-Host("Enter extname: ")
param ($filename, $dbs, $extname)

if($extname -match '([ _]).*')
{
    Write-Host 'Space and underscore characters are not allowed'
    exit
}



Write-Host $filename
Write-Host $dbs
Write-Host $extname

#get file and modify
#absolute path
#$filePathToTask ="D:\TemplateUpdateDBs\InstanceTemplate.azure.setup.sit.xml""
#relative path
$filePathToTask ="..\TemplateUpdateDBs\InstanceTemplate.azure.setup.sit.xml"
$xml = New-Object XML
$xml.Load($filePathToTask)

$databases = 'Database';
$foundNode = $xml.SelectSingleNode('//Instance/components/database[@id="Database"]')
For ($i = 1; $i -lt $dbs; $i++)  
{
    $count = "{0:00}" -f $i
    $tags = "<database id='Database$count' depends='Innovator SelfServiceReporting Vault Conversion Agent OAuth'>"
    $tags = $tags + '<SqlServer>${MSSQL.Server}</SqlServer>'
    $tags = $tags + "<DatabaseName>student-$count-$extname</DatabaseName>"
    $tags = $tags + "<DbConnectionId>student-$count</DbConnectionId>"
    $tags = $tags + '<InnovatorLogin>${MSSQL.Innovator.User}</InnovatorLogin>'
    $tags = $tags + '<InnovatorPassword type="EnvironmentVariable">MSSQL.Innovator.Password</InnovatorPassword>'
    $tags = $tags + '<InnovatorUrl>${Innovator.Load.Balancer.Url}/${Name.Of.Innovator.Instance}</InnovatorUrl>'
    $tags = $tags + '</database>'

    $newNode = [xml]$tags
    $newNode = $xml.ImportNode($newNode.database,$true)
    $components = $xml.Instance.components
    $components.InsertAfter($newNode,$foundNode) |out-null
    $foundNode = $xml.SelectSingleNode("//Instance/components/database[@id='Database$count']")

    $databases = $databases +',' + "Database$count"
}

#select and change node
$componentsdata = $databases + ',Innovator, SelfServiceReporting, Vault, AlternateVault, Conversion, Agent, OAuth'
$setup =  $xml.SelectSingleNode("//setup")
$setup.components = $componentsdata


For ($k = 1; $k -lt $dbs; $k++) 
{
    $count = "{0:00}" -f $k
    $database2agent= "<database2agent database='Database$count' agent='Agent' />"
    $newdatabase2agent = [xml]$database2agent
    $newdatabase2agent = $xml.ImportNode($newdatabase2agent.database2agent,$true)
    $xml.Instance.link.AppendChild($newdatabase2agent)  | out-null 

     $database2innovator="<database2innovator database='Database$count' innovator='Innovator' />"
    $newdatabase2innovator = [xml]$database2innovator
    $newdatabase2innovator = $xml.ImportNode($newdatabase2innovator.database2innovator,$true)
    $xml.Instance.link.AppendChild($newdatabase2innovator)  | out-null 


     $database2ssr = "<database2ssr database='Database$count' ssr='SelfServiceReporting' />"
    $newdatabase2ssr  = [xml]$database2ssr 
    $newdatabase2ssr  = $xml.ImportNode($newdatabase2ssr.database2ssr ,$true)
    $xml.Instance.link.AppendChild($newdatabase2ssr )  | out-null 

    $vault2database1=  "<vault2database database='Database$count' vault='Vault' />"
    $newvault2database1 = [xml]$vault2database1
    $newvault2database1 = $xml.ImportNode($newvault2database1.vault2database,$true)
    $xml.Instance.link.AppendChild($newvault2database1)  | out-null 

    $vault2database2= "<vault2database database='Database$count' vault='AlternateVault' />"
    $newvault2database2 = [xml]$vault2database2
    $newvault2database2 = $xml.ImportNode($newvault2database2.vault2database,$true)
    $xml.Instance.link.AppendChild($newvault2database2)  | out-null 

    $conversion2database = "<conversion2database database='Database$count' conversion='Conversion'  />"
    $newconversion2database = [xml]$conversion2database
    $newconversion2database = $xml.ImportNode($newconversion2database.conversion2database,$true)
    $xml.Instance.link.AppendChild($newconversion2database)  | out-null 
   
}

$xml.Save($filePathToTask)
