package com.site.common.remote;

import org.junit.Test;

import java.util.Map;

import static org.junit.Assert.assertTrue;

/**
 * Created by IntelliJ IDEA.
 * User: cwalquist
 * Date: Apr 26, 2010
 * Time: 3:52:14 PM
 * To change this template use File | Settings | File Templates.
 */
public class AnthillConnectionTest {
  @Test
  public void mytest() throws Exception {
    Map e = new AnthillConnection().config();
    Map<String, String> env = System.getenv();
    assertTrue(env.get("AHPTOOLS_ENV")==null);
    assertTrue(env.get("AHPTOOLS_CFG")==null);

    assertTrue(e.get(":host_name").toString().equals("ahp-development.local"));
  }
}
