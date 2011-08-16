package com.site.anthill.reports;

import com.site.common.remote.RemoteReport;
import com.urbancode.anthill3.domain.reporting.*;
import com.urbancode.anthill3.domain.agent.Agent;
import com.urbancode.anthill3.domain.agent.AgentFactory;
import com.urbancode.devilfish.client.ServiceEndpoint;

import java.util.*;
import com.urbancode.anthill3.domain.servergroup.*;


public class PropertiesForAgentsInChosenEnvironment extends RemoteReport {

    // These params are supplied dynamically by AHP, but define it here in order to run remotely.
    private String environment = "Rapax-Asia Production";

    public String getDescription() {
        return "List properties for each agent in a selected environment";
    }

    protected ReportMetaData metadataScript() throws Exception {
        ReportMetaData rmd = new ReportMetaData();


        rmd.addColumn("Environment");
        rmd.addColumn("Agent");
        rmd.addColumn("Properties");

        SelectParamMetaData envDropdown = new SelectParamMetaData();
        envDropdown.setName("environment");
        envDropdown.setLabel("Environment");
        envDropdown.setDescription("Choose an environment");


        envDropdown.setName("environment");
        envDropdown.setLabel("Environment");

        // Collect projects for populating dropdown
        ServerGroup[] envs = ServerGroupFactory.getInstance().restoreAll();
        String[] labels = new String[envs.length + 1];
        String[] values = new String[envs.length + 1];

        for (int i = 0; i < envs.length; i++) {
            labels[i] = envs[i].getName();
            values[i] = labels[i];
        }

        envDropdown.setLabels(labels);
        envDropdown.setValues(values);
        envDropdown.setDescription("Select an environment");
        rmd.addParameter(envDropdown);

        return rmd;
    }


    protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {

        HashMap endpointsToAgents = new HashMap();
        ReportOutput output = new ReportOutput(metaData);

        ServerGroup[] envs = ServerGroupFactory.getInstance().restoreAll();

        for (int i = 0; i < envs.length; i++) {
            String name = envs[i].getName();
            if (name.contains(environment)) {
                ServiceEndpoint[] agents = envs[i].getServerArray();
                for (int j = 0; j < agents.length; j++) {
                    Agent agent = null;
                    ServiceEndpoint endpoint = agents[j];
                    if (endpointsToAgents.containsKey(endpoint)) {
                      agent = (Agent) endpointsToAgents.get(endpoint);
                    } else {
                      agent = AgentFactory.getInstance().restoreByEndpoint(endpoint);
                      endpointsToAgents.put(endpoint, agent);
                    }
                    ReportRow row = new ReportRow(output, "Environment");
                    row.setColumnValue("Environment", envs[i].getName());
                    row.setColumnValue("Agent", agent.getName() + "\n");

                    StringBuffer propertiesString = new StringBuffer();
                    for (String name2 : agent.getEditablePropertyArray()) {
                      if (name2.equals("install.service.name")) { continue; }
                      propertiesString.append(name2);
                      propertiesString.append(" = ");
                      propertiesString.append(agent.getPropertyValue(name2));
                      propertiesString.append("<br />");
                    }
                    row.setColumnValue("Properties", propertiesString.toString());

                    output.addRow(row);
                }
            }
        }

        return output;
    }
}