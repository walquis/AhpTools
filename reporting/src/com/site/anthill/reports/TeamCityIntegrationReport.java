package com.site.anthill.reports;

import com.urbancode.anthill3.domain.project.*;
import com.urbancode.anthill3.domain.workflow.*;
import com.urbancode.anthill3.domain.reporting.*;
import com.urbancode.anthill3.domain.trigger.Trigger;
import com.urbancode.anthill3.domain.triggercode.TriggerCodeFactory;
import com.urbancode.anthill3.domain.triggercode.TriggerCode;
import com.site.common.remote.RemoteReport;

public class TeamCityIntegrationReport extends RemoteReport {

  public String getDescription() {
    return "Returns a list of all Release Candidate URL's in TeamCity";
  }

  protected ReportMetaData metadataScript() {
    ReportMetaData rmd = new ReportMetaData();
     rmd.addColumn("Project");
     rmd.addColumn("TeamCity RC build URL");
     rmd.addColumn("Trigger Code");
    return rmd;
  }

  protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {
    ReportOutput output = new ReportOutput(metaData);
    ProjectFactory factory = ProjectFactory.getInstance();
    TriggerCodeFactory triggerFactory = TriggerCodeFactory.getInstance();
    Project[] projects = factory.restoreAllActive();
    for (Project project : projects) {
      Workflow[] workflows = project.getOriginatingWorkflowArray();
      for (Workflow workflow : workflows) {
        ReportRow row = new ReportRow(output, null);
        String description = workflow.getDescription();

        Trigger[] triggers = workflow.getTriggerArray();
        String code = " ";
        if (triggers.length > 0) {
          TriggerCode triggerCode = triggerFactory.restoreForOwner(triggers[0]);
          code = triggerCode.getCode();
        }

        if (description == null) description = " ";
        row.setColumnValue("Project", project.getName());
        row.setColumnValue("TeamCity RC build URL", description);
        row.setColumnValue("Trigger Code", code);
        output.addRow(row);
      }
    }
    return output;
  }
}
