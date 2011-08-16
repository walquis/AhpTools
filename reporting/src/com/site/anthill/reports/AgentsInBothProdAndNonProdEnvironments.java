package com.site.anthill.reports;

import com.site.common.remote.RemoteReport;
import com.urbancode.anthill3.domain.reporting.*;
import java.sql.*;

import org.apache.log4j.Logger;

public class AgentsInBothProdAndNonProdEnvironments extends RemoteReport {

    public String getDescription() {
        return "List of applications that have been deployed to production, based on 'Production Deployed' status";
    }

    protected ReportMetaData metadataScript() throws Exception {
        ReportMetaData rmd = new ReportMetaData();

        rmd.addColumn("ID");
        rmd.addColumn("Host");
        rmd.addColumn("Name");
        rmd.addColumn("LastStartTime");
        rmd.addColumn("line break");

        return rmd;
    }

    protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {

        String query = "select id, host, name, last_start_time from agent a\n" +
                "where a.id in (\n" +
                " select distinct agent_id from server_group_endpoints sge\n" +
                ")\n" +
                "and a.id in (\n" +
                " select distinct agent_id from server_group_endpoints sge\n" +
                "  where server_group_id in (\n" +
                "    select id from server_group where name like '%ALL PRODUCTION%'\n" +
                "  )\n" +
                ")\n" +
                "and a.id in (\n" +
                " select distinct agent_id from server_group_endpoints sge\n" +
                "  where server_group_id in (\n" +
                "    select id from server_group where name like '%All non-prod%'\n" +
                "  )\n" +
                ")\n" +
                "and a.isdeleted = 0\n" +
                "and a.isignored = 0\n";

        ReportOutput output = new ReportOutput(metaData);

        String password = System.getenv("AHP_DB_PASS");

        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Connection conn = DriverManager.getConnection("jdbc:sqlserver://swp-chisql01v:1433;DatabaseName=deploy", "drwdeploy", password);
        try {
            Statement st = conn.createStatement();

            ResultSet rs = st.executeQuery(query);
            while (rs.next()) {
                ReportRow row = new ReportRow(output, null);
                row.setColumnValue("ID"              , rs.getString("ID"    ));
                row.setColumnValue("Host"            , rs.getString("Host"  ));
                row.setColumnValue("Name"            , rs.getString("Name"   ));
                row.setColumnValue("LastStartTime"   , rs.getString("last_start_time"   ));

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