package com.site.anthill.reports;

import com.site.common.remote.RemoteReport;
import com.urbancode.anthill3.dashboard.BuildLifeWorkflowCaseSummary;
import com.urbancode.anthill3.dashboard.DashboardFactory;
import com.urbancode.anthill3.domain.buildlife.BuildLife;
import com.urbancode.anthill3.domain.buildlife.BuildLifeFactory;
import com.urbancode.anthill3.domain.jobtrace.JobTrace;
import com.urbancode.anthill3.domain.project.Project;
import com.urbancode.anthill3.domain.project.ProjectFactory;
import com.urbancode.anthill3.domain.reporting.ReportMetaData;
import com.urbancode.anthill3.domain.reporting.ReportOutput;
import com.urbancode.anthill3.domain.reporting.ReportRow;
import com.urbancode.anthill3.domain.reporting.SelectParamMetaData;
import com.urbancode.anthill3.domain.userprofile.UserProfileFactory;
import com.urbancode.anthill3.domain.workflow.WorkflowCase;
import com.urbancode.anthill3.domain.workflow.WorkflowCaseFactory;
import com.urbancode.anthill3.services.jobs.JobStatusEnum;
import com.urbancode.commons.util.Duration;

import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

public class PerProjectDeploymentReport extends RemoteReport {

  private String project = "101";      // 101 - DDT Gem, 25 - Position Server

  public String getDescription() {
    return "Sample Pivot - Rows: Project, Environment, Agent, Version; Columns: End Month, Status; Values: Count of Status";
  }

  protected ReportMetaData metadataScript() throws Exception {
    ReportMetaData rmd = new ReportMetaData();

    // Add some projects to choose from
    SelectParamMetaData params = new SelectParamMetaData();
    Project[] allMyProjectsArray = ProjectFactory.getInstance().restoreAllActive();
    String[] labels = new String[allMyProjectsArray.length + 1];
    String[] values = new String[allMyProjectsArray.length + 1];

    labels[0] = "All Projects";
    values[0] = "allProjects";

    for (int i = 0; i < allMyProjectsArray.length; i++) {
      labels[i+1] = allMyProjectsArray[i].getName();
      values[i+1] = allMyProjectsArray[i].getId().toString();
    }

    params.setLabels(labels);
    params.setValues(values);
    params.setName("project");
    params.setLabel("Project");
    params.setDescription("Select the project, or 'All Projects'.");
    rmd.addParameter(params);

    // Configure columns
    rmd.addColumn("Project");
    rmd.addColumn("Workflow");
    rmd.addColumn("Environment");
    rmd.addColumn("Version");
    rmd.addColumn("Agent");
    rmd.addColumn("Status");
    rmd.addColumn("Originating End Date");
    rmd.addColumn("Workflow End Date");
    rmd.addColumn("End Month");
    rmd.addColumn("Duration");
    rmd.addColumn("line break");
    return rmd;
  }

  protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {
    // Figure out the project to use. "project" is the name of the parameter in the meta data script.
    Long projectId = null;
    if (!(project == null || project.equals("allProjects"))) {
      projectId = Long.parseLong(project);
    }

    Calendar earliest = Calendar.getInstance(UserProfileFactory.getTimeZone());
    earliest.set(Calendar.YEAR, 2008);
    earliest.set(Calendar.MONTH, Calendar.JANUARY);
    earliest.set(Calendar.DAY_OF_MONTH, 1);
    earliest.set(Calendar.HOUR, 0);
    earliest.set(Calendar.MINUTE, 0);
    earliest.set(Calendar.SECOND, 0);
    earliest.set(Calendar.MILLISECOND, 0);

    Date startDate = earliest.getTime();
    Date endDate = Calendar.getInstance().getTime();  // i.e., now

    BuildLifeWorkflowCaseSummary[] summaries =
      DashboardFactory.getInstance().getBuildLifeWorkflowSummaries(projectId, startDate, endDate);

    ReportOutput output = new ReportOutput(metaData);
    Calendar end = Calendar.getInstance(UserProfileFactory.getTimeZone());

    for (int i = 0; i < summaries.length; i++) {
      BuildLife buildLife = BuildLifeFactory.getInstance().restore(summaries[i].getBuildLifeId());
      WorkflowCase workflow = WorkflowCaseFactory.getInstance().restore(summaries[i].getCaseId());
      WorkflowCase originating = WorkflowCaseFactory.getInstance().restoreOriginatingForBuildLife(buildLife);
      JobTrace[] jobs = workflow.getJobTraceArray();

      if (workflow.getWorkflow().isOriginating()) continue;   // Skip originating workflows; they only copy artifacts.

      for (int j = 0; j < jobs.length; j++) {
        // We create a row for each job run on an agent to allow easy pivoting.
        ReportRow row = new ReportRow(output, null);
        row.setColumnValue("Project", summaries[i].getProjectName());
        row.setColumnValue("Workflow", summaries[i].getWorkflowName());
        row.setColumnValue("Environment", workflow.getServerGroup() == null ? "null" : workflow.getServerGroup().getName());
        row.setColumnValue("Version", summaries[i].getLatestStamp());
        row.setColumnValue("Agent", jobs[j].getAgent() == null ? "null" : jobs[j].getAgent().getName());
        row.setColumnValue("Status", summaries[i].getStatus().getName());
          JobStatusEnum js = JobStatusEnum.NOT_NEEDED;

        if (originating.getEndDate() != null && summaries[i].getEndDate() != null) {
          row.setColumnValue("Originating End Date", String.valueOf(originating.getEndDate()));
          row.setColumnValue("Workflow End Date", String.valueOf(summaries[i].getEndDate()));

          // Include the month separately to make it easier to pivot
          end.setTimeInMillis(summaries[i].getEndDate().getTime());
          row.setColumnValue("End Month", end.getDisplayName(Calendar.MONTH, Calendar.LONG, Locale.ENGLISH));

          // Calculate Duration as a potential input to cycle time
          Duration duration = new Duration(originating.getEndDate(), summaries[i].getEndDate());
          row.setColumnValue("Duration", duration.toString());
        }

        row.setColumnValue("line break", "\n"); // AHP screws up line breaks outputting csv, so we force it here with \n
        output.addRow(row);
      }
    }
    return output;
  }
}
