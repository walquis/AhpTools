Description
-----------
Two sets of tools:

AHP admin tools:
A client-side set of JRuby API wrappers for adding agents, listing environments, setting security parameters, and setting properties.
Also included are a couple of early prototypes, somewhat in disrepair: new_project and add_status_steps


AHP report-generating tools:
In the "reporting" hierarchy, a Java report builder that supports testing reports remotely, and uploading to AHP.


Installation
------------
- The JRuby wrappers require at least JRuby 1.3.1.
- These commands have been run on both Linux RHEL and Windows.
- Set the AHPTOOLS_ENV environment variable to either development or production.
- If using the reporting tools, set AHP_DB_PASS to the password for your SQL Server database.


Example comamnds:
------------
We don't use "Build Master" role in our shop, so this tool helped us to clean it out...
NOTE: "all" is a special case of resource_name.  All other names act as matches.

C:\AhpTools> jruby commands\bin\set_security --resource_type env --resource_name all --action read,use,write --role "Build Master" --remove


--agents can be a comma-separated list.  The environment named in --env must already exist.

C:\AhpTools> jruby commands/bin/add_agents  --agents energyclerk1 --env 'All Production Agents'


Setting properties in the UI can be a click-fest.  These property-setting commands work for projects, environments, workflows, and agents
As with set_security, the resource_name can be a regex match.
--no_exec is good for dry runs.
--remove takes properties away.

C:\AhpTools> jruby commands\bin\set_property --resource_type project --resource_name "DDT Gem" --key howYaDoin --value FineThanks
Project = DDT Gem: Adding property howYaDoin = FineThanks...

C:\AhpTools> jruby commands\bin\set_property --resource_type project --resource_name "DDT Gem" --key howYaDoin --remove
Project = DDT Gem: Removing property howYaDoin with value 'FineThanks'

C:\AhpTools> jruby commands\bin\set_property --resource_type workflow --resource_name "1.0.a Install DDT" --key aTestProperty --value FineThanks
Workflow = 1.0.a Install DDT: Updating property aTestProperty to 'FineThanks'.  Old value = 'TerribleWhyDoYouAsk'

Can use a comma-separated list of resource_names...

C:\AhpTools> jruby commands\bin\set_property --resource_type workflow --resource_name "1.0.a Install DDT,1.0.b Dynamic I
nstall DDT" --key aTestProperty --value FineThanks
Workflow = 1.0.a Install DDT: Adding property aTestProperty = FineThanks...
Workflow = 1.0.b Dynamic Install DDT: Adding property aTestProperty = FineThanks...

Or a regex match, e.g., "Install DDT", which resolves to the same couple of workflows...

C:\AhpTools> jruby commands\bin\set_property --resource_type workflow --resource_name "Install DDT" --key aTestProperty --value FineThanks
Workflow = 1.0.a Install DDT: Updating property aTestProperty to 'FineThanks'.  Old value = 'FineThanks'
Workflow = 1.0.b Dynamic Install DDT: Updating property aTestProperty to 'FineThanks'.  Old value = 'FineThanks'

And now remove them.  First, use --no_exec to test that what you think is going to happen, is really what is going to happen...

C:\AhpTools> jruby commands\bin\set_property --resource_type workflow --resource_name "Install DDT" --key aTestProperty --value FineThanks --remove --no_exec
no_exec set, not going to do anything
Workflow = 1.0.a Install DDT: Removing property aTestProperty with value 'FineThanks'
Workflow = 1.0.b Dynamic Install DDT: Removing property aTestProperty with value 'FineThanks'
no_exec set, didn't do anything

OK, looks good; go ahead and pull the trigger (--value is superfluous but harmless here)...

C:\AhpTools> jruby commands\bin\set_property --resource_type workflow --resource_name "Install DDT" --key aTestProperty --value FineThanks --remove
Workflow = 1.0.a Install DDT: Removing property aTestProperty with value 'FineThanks'
Workflow = 1.0.b Dynamic Install DDT: Removing property aTestProperty with value 'FineThanks'



Using the report creation tools:
------------
- Open the code up in your IDE.
- Edit the "report" variable in RemoteReportServiceTest.java to reflect the report you're working with.
- Run the shouldRunReport() test.

- If you want to upload the report to AHP, run the createReportOnServer() test.  If it's already there and you want to replace it, first run the deleteReportFromServer() test.


15 Sep 2011 Release Notes
-----------
- Copied in jars from 3.7.5_101041.

19 May 2010 Release Notes
-----------
- Environment:
	- AnthillPro 3.7.3_68296, running on RedHat-Linux or Windows, using SQL Server DB with [driver version?]
	- AhpTools.ipr is a JetBrains IntelliJ IDEA 9.x project file, as is reporting/reporting.ipr
	