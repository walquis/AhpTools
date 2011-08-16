package com.site.anthill.agentfilterscripts;

import com.urbancode.anthill3.domain.agent.Agent;
import com.urbancode.anthill3.domain.script.agentfilter.criteria.Criteria;
import com.urbancode.anthill3.domain.script.agentfilter.criteria.Where;
import com.urbancode.anthill3.runtime.scripting.helpers.PropertyLookup;

import java.util.ArrayList;

/**
 * This is an example of an Agent Filter report. It probably isn't possible to run
 * from here, but the syntax completion of the IDE makes development of these a bit
 * easier. Unlike reports, there's no way to sync filters remotely; you'll have to
 * copy your implementation of the filter method to the appropriate field on AHP.
 */
// NOTE: This Criteria is anthill3.domain.script.agentfilter.criteria.Criteria, a different namespace than
//    a Job PreCondition criteria.
public class PropertyIncludesAgentNames extends Criteria {

  private String propertyName;

  public PropertyIncludesAgentNames(String propertyName) {
    this.propertyName = propertyName;
  }

  public Agent[] filter(Agent[] agents) {
    ArrayList list = new ArrayList();

    for (int i = 0; i < agents.length; i++) {
      System.out.println(PropertyLookup.get(propertyName) + " : " + agents[i].getName());
      if (PropertyLookup.contains(propertyName, agents[i].getName())) {
        list.add(agents[i]);
      }
    }

    Agent[] result = new Agent[list.size()];
    list.toArray(result);
    return result;
  }

  public Criteria evaluate() {
    return Where.is(new PropertyIncludesAgentNames("agents"));
  }
}