package com.site.anthill.jobpreconditionscripts;

import com.urbancode.logic.Criteria;
import com.urbancode.anthill3.runtime.scripting.helpers.*;
import com.urbancode.anthill3.services.agent.AgentManager;
import com.urbancode.anthill3.services.agent.AgentStatus;

import java.util.regex.Pattern;

// NOTE: Job PreConditions return urbancode.logic.Criteria, which differ from agent filters.
public class MeetsJobPreCondition extends Criteria {
  public boolean matches(Object obj) throws Exception {
      String k = AgentVarHelper.getCurrentAgentVar("sys/os.name");
      boolean res = Pattern.compile("Windows.*").matcher(k).find();
      AgentStatus status = AgentManager.getInstance().getAgentStatus(AgentHelper.getCurrent());

      return res;
  }
}
