package com.site.anthill.reports;

import com.urbancode.anthill3.domain.project.*;
import com.urbancode.anthill3.domain.workflow.*;
import com.urbancode.anthill3.domain.reporting.*;
import com.site.common.remote.RemoteReport;

import java.io.Serializable;

public class ProjectListReport extends RemoteReport implements Serializable {

  public String getDescription() {
    return "Returns a list of all projects and workflows.";
  }

  protected ReportMetaData metadataScript() {
    ReportMetaData rmd = new ReportMetaData();
    rmd.addColumn("Project ID");
    rmd.addColumn("Project");
    rmd.addColumn("Workflow");
    return rmd;
  }

  protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {
    ReportOutput output = new ReportOutput(metaData);
    Project[] projects = ProjectFactory.getInstance().restoreAll();

    for (int i = 0; i < projects.length; i++) {
        ReportRow row = new ReportRow(output, null);
      row.setColumnValue("Project ID", projects[i].getId().toString());
      row.setColumnValue("Project", projects[i].getName());
        row.setColumnValue("Workflow", "");
        output.addRow(row);

        Workflow[] workflows = projects[i].getWorkflowArray();
        for (int w=0; w<workflows.length; w++) {
          row = new ReportRow(output, null);
          row.setColumnValue("Project ID", "");
          row.setColumnValue("Project", "");
          row.setColumnValue("Workflow", workflows[w].getName());
          output.addRow(row);
        }
    }
    return output;
  }
}
