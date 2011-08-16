package com.site.anthill.reports;

import com.site.common.remote.RemoteReport;
import com.urbancode.anthill3.dashboard.BuildLifeWorkflowCaseSummary;
import com.urbancode.anthill3.dashboard.DashboardFactory;
import com.urbancode.anthill3.domain.buildlife.BuildLife;
import com.urbancode.anthill3.domain.buildlife.BuildLifeFactory;
import com.urbancode.anthill3.domain.jobtrace.JobTrace;
import com.urbancode.anthill3.domain.project.Project;
import com.urbancode.anthill3.domain.project.ProjectFactory;
import com.urbancode.anthill3.domain.reporting.*;
import com.urbancode.anthill3.domain.userprofile.UserProfileFactory;
import com.urbancode.anthill3.domain.workflow.WorkflowCase;
import com.urbancode.anthill3.domain.workflow.WorkflowCaseFactory;
import com.urbancode.commons.util.Duration;

import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.HashMap;
import java.sql.*;

public class WhatsBeenDeployed extends RemoteReport {

    // These params are supplied dynamically by AHP, but define here in order to test remotely.
    private String project = "Skippy-Grains Client";
    private String deployStatus = "production deployed";

    public String getDescription() {
        return "List of applications that have been deployed (to prod or elsewhere), based on chosen Deploy Status";
    }

    protected ReportMetaData metadataScript() throws Exception {
        ReportMetaData rmd = new ReportMetaData();

        // Add some projects to choose from
        SelectParamMetaData projectDropdown = new SelectParamMetaData();
        projectDropdown.setName("project");
        projectDropdown.setLabel("Project");

        // Collect projects for populating dropdown
        Project[] allMyProjectsArray = ProjectFactory.getInstance().restoreAllActive();
        String[] labels = new String[allMyProjectsArray.length + 1];
        String[] values = new String[allMyProjectsArray.length + 1];

        labels[0] = "All Projects";
        values[0] = "allProjects";

        for (int i = 0; i < allMyProjectsArray.length; i++) {
            labels[i + 1] = allMyProjectsArray[i].getName();
            values[i + 1] = labels[i + 1];
        }

        projectDropdown.setLabels(labels);
        projectDropdown.setValues(values);
        projectDropdown.setDescription("Select the project, or 'All Projects'.");
        rmd.addParameter(projectDropdown);

        SelectParamMetaData statusDropdown = new SelectParamMetaData();
        statusDropdown.setName("deployStatus");
        statusDropdown.setLabel("Deploy Status");

        statusDropdown.setLabels(new String[] { "production deployed", "non-prod deployed"});
        statusDropdown.setValues(new String[] { "production deployed", "non-prod deployed"});
        statusDropdown.setDescription("Select a status");
        rmd.addParameter(statusDropdown);


        // Configure columns for report output.
        rmd.addColumn("DeployID");
        rmd.addColumn("Project");
        rmd.addColumn("BuildLife");
        rmd.addColumn("Agent");
        rmd.addColumn("Date");
        rmd.addColumn("Environment");
        rmd.addColumn("BuildLabel");
        rmd.addColumn("User");
        rmd.addColumn("line break");
        return rmd;
    }

    protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {

        String query = "select p.name as Project, bl.id as BuildLife, wfc.id as DeployID, jt.end_date as Date, env.name as Environment, a.name as Agent, bl.latest_stamp_value as BuildLabel, su.name as [User]\n" +
                "FROM job_trace jt\n" +
                "join project p on jt.project_id = p.id\n" +
                "join workflow_case wfc on wfc.id = jt.workflow_case_id\n" +
                "join server_group env on wfc.server_group_id = env.id\n" +
                "join build_life bl on bl.id = wfc.build_life_id\n" +
                "join build_request br on br.id = wfc.request_id\n" +
                "join sec_user su on su.id = br.user_id\n" +
                "left outer join agent a on jt.agent_id = a.id\n" +
                "where jt.workflow_case_id in (\n" +
                "\t/* Pick jobs whose workflows have the desired build-life status */\n" +
                "\tselect workflow_case_id from job_trace jt\n" +
                "\tjoin build_life_status bls on jt.id = bls.job_trace_id\n" +
                "\tjoin status s on bls.status_id = s.id\n" +
                "\twhere s.name = '" + deployStatus + "'\t\n" +
                ")\n" +
                "and jt.status = 'Success'  /* These jobs will have NULL for agent */\n";

        String orderByClause = " order by DeployID desc, Project, BuildLife desc, Agent";

        String projectWhereClause = " AND p.name = '" + project + "' ";
        if (project.equals("allProjects")) {
            projectWhereClause = "";
        }
        //System.err.println("PROJECT CHOICE: " + project);

        ReportOutput output = new ReportOutput(metaData);

        String password = System.getenv("AHP_DB_PASS");

        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection conn = DriverManager.getConnection("jdbc:sqlserver://swp-chisql01v:1433;DatabaseName=deploy", "drwdeploy", password);
        try {
            Statement st = conn.createStatement();
            String finalQuery = query + projectWhereClause + orderByClause;
            // System.err.println("FINAL QUERY: " + finalQuery);

            HashMap h = new HashMap();

            ResultSet rs = st.executeQuery(finalQuery);
            while (rs.next()) {
                String key = rs.getString("DeployID") + rs.getString("Agent");
                if (h.containsKey(key)) {
                    continue;
                }
                h.put(key,"blah");  // Keep rows unique according to our business logic...
                ReportRow row = new ReportRow(output, null);
                row.setColumnValue("DeployID"   , rs.getString("DeployID"   ));
                row.setColumnValue("Project"    , rs.getString("Project"    ));
                row.setColumnValue("BuildLife"  , rs.getString("BuildLife"  ));
                row.setColumnValue("Agent"      , rs.getString("Agent"      ));
                row.setColumnValue("Date"       , rs.getString("Date"       ));
                row.setColumnValue("Environment", rs.getString("Environment"));
                row.setColumnValue("BuildLabel" , rs.getString("BuildLabel" ));
                row.setColumnValue("User"       , rs.getString("User"       ));

                row.setColumnValue("line break" , "\n"); // AHP screws up line breaks outputting csv, so we force it here with \n
                output.addRow(row);
            }
            rs.close();
            st.close();
        } catch (SQLException se) {
            System.err.println("Threw a SQLException:");
            System.err.println(se.getMessage());
        }

        return output;
    }
}