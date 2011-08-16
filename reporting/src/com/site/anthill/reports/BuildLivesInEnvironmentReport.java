package com.site.anthill.reports;

import com.urbancode.anthill3.domain.reporting.*;
import com.urbancode.anthill3.domain.workflow.*;
import com.urbancode.anthill3.domain.servergroup.ServerGroup;
import com.urbancode.anthill3.domain.script.job.Property;
import com.urbancode.logic.Logic;
import com.urbancode.logic.Criteria;
import com.urbancode.logic.NotCriteria;
import com.site.common.remote.RemoteReport;

import java.util.HashMap;
import java.util.Map;

public class BuildLivesInEnvironmentReport extends RemoteReport {

  private final String environment = "Gareth Reeves"; 

  public String getDescription() {
    return "Shows what build lives are using environments. Useful for locked env's that need to be deleted. " +
      "Use the Search page to find the build lives and delete them, then delete the env.";
  }

  protected ReportMetaData metadataScript() {
    ReportMetaData rmd = new ReportMetaData();
    rmd.addColumn("Build Life ID");

    // Configure inputs
    TextParamMetaData param = new TextParamMetaData();
    param.setName("environment");
    param.setLabel("Environment Name");
    param.setDescription("Enter the name of an Environment");
    param.setRequired(true);
    param.setDefaultValue("Delete Me");
    rmd.addParameter(param);

    return rmd;
  }

  protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {
    ReportOutput output = new ReportOutput(metaData);
    WorkflowCase[] workflowCases = WorkflowCaseFactory.getInstance().restoreAll();
    Map ids = new HashMap();

    for (int x = 0; x < workflowCases.length; x++) {
      ServerGroup serverGroup = workflowCases[x].getServerGroup();
      if (environment.equals(serverGroup.getName())) {
        Long id = workflowCases[x].getBuildLife().getId();

        // Skip duplicates
        if (ids.get(id) == null) {
          ReportRow row = new ReportRow(output, null);
          row.setColumnValue("Build Life ID", id.toString());
          output.addRow(row);
          ids.put(id, id.toString());
        }
      }
    }
    return output;
  }
}
