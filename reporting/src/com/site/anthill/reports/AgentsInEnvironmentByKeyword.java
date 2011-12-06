package com.site.anthill.reports;

import com.site.common.remote.RemoteReport;
import com.urbancode.anthill3.domain.agent.Agent;
import com.urbancode.anthill3.domain.agent.AgentFactory;
import com.urbancode.anthill3.domain.reporting.*;
import com.urbancode.anthill3.domain.servergroup.ServerGroup;
import com.urbancode.anthill3.domain.servergroup.ServerGroupFactory;
import com.urbancode.anthill3.services.agent.AgentManager;
import com.urbancode.anthill3.services.agent.AgentStatus;
import com.urbancode.devilfish.client.ServiceEndpoint;

import java.util.*;

public class AgentsInEnvironmentByKeyword extends RemoteReport {
    // These params are supplied dynamically by AHP, but define it here in order to run remotely.
    private String keyword = "Matt's";

    public String getDescription() {
        return "Shows agents in all environments containing the specified keyword";
    }

    protected ReportMetaData metadataScript() throws Exception {
        ReportMetaData rmd = new ReportMetaData();

        // Configure columns
        rmd.addColumn("Environments");
        rmd.addColumn("Agents");
        rmd.addColumn("Status");

        // Configure inputs
        TextParamMetaData param = new TextParamMetaData();
        param.setName("keyword");
        param.setLabel("Keyword");
        param.setDescription("Enter part of the name of an environment, e.g. Production.");
        param.setRequired(true);
        param.setDefaultValue("Production");
        rmd.addParameter(param);

        return rmd;
    }

    protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {

        class AgentRetriever {
            Map endpointsToAgents = new HashMap();

            Agent retrieveAgentForEndpoint(ServiceEndpoint endpoint) throws Exception {
                Agent result = null;

                if (endpointsToAgents.containsKey(endpoint)) {
                    result = (Agent) endpointsToAgents.get(endpoint);
                } else {
                    result = AgentFactory.getInstance().restoreByEndpoint(endpoint);
                    endpointsToAgents.put(endpoint, result);
                }
                return result;
            }
        }

        ReportOutput output = new ReportOutput(metaData);

        ServerGroup[] envs = ServerGroupFactory.getInstance().restoreAll();

        for (int i = 0; i < envs.length; i++) {
            String name = envs[i].getName();
            if (name.toLowerCase().contains(keyword.toLowerCase())) {
                ServiceEndpoint[] agents = envs[i].getServerArray();
                AgentRetriever ar = new AgentRetriever();
                for (int j = 0; j < agents.length; j++) {
                    Agent agent = ar.retrieveAgentForEndpoint(agents[j]);
                    ReportRow row = new ReportRow(output, "Environment");
                    row.setColumnValue("Environments", envs[i].getName());
                    row.setColumnValue("Agents", agent.getName() + "\n");
                    AgentStatus status = AgentManager.getInstance().getAgentStatus(agent);
                    if (status != null && status.isOnline()) {
                        row.setColumnValue("Status", "online");
                    } else {
                        row.setColumnValue("Status", "OFFLINE");
                    }
                    output.addRow(row);
                }
            }
        }
        return output;
    }
}