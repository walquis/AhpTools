package com.site.common.remote;

import com.urbancode.anthill3.main.client.AnthillClient;
import com.urbancode.anthill3.persistence.UnitOfWork;
import com.urbancode.anthill3.domain.persistent.PersistenceException;
import org.yaml.snakeyaml.Yaml;

import java.io.File;
import java.io.FileReader;
import java.net.URL;
import java.util.Map;

public class AnthillConnection {
  private UnitOfWork uow;

  public void open() throws Exception {

    Map e = config();

    String serverHost = e.get(":host_name").toString();
    int serverPort = Integer.parseInt(e.get(":host_port").toString());
    String userName = e.get(":username").toString();
    String password = e.get(":password").toString();

    try {
      // obtain connection to the Anthill server
      AnthillClient anthill = AnthillClient.connect(serverHost, serverPort, userName, password);
      // create a Unit of Work
      uow = anthill.createUnitOfWork();
    } catch (NullPointerException npe) {
      throw new RuntimeException("Failed to connect to server:", npe);
    }
  }

  public Map config_db() throws Exception {
    return config_for_key(ahptools_env_yaml_key() + "_db");
  }

  public Map config() throws Exception {
    return config_for_key(ahptools_env_yaml_key());
  }

  private Map config_for_key(String key) throws Exception {
      Yaml yaml = new Yaml();
      Map<String, String> env = System.getenv();
      String cfg_path = env.get("AHPTOOLS_CFG");
      if (cfg_path == null || cfg_path.equals("")) cfg_path = "conf/config.yml";
      cfg_path = new File(cfg_path).getCanonicalPath();
      System.out.println("AHPTOOLS config path = " + cfg_path); 
      Map e = (Map) yaml.load(new FileReader(cfg_path));
      return (Map) e.get(key);
    }

  private String ahptools_env_yaml_key()  {
    Map<String, String> env = System.getenv();
    String ahptools_env = env.get("AHPTOOLS_ENV");
    if (ahptools_env==null || ahptools_env=="") ahptools_env = "development";
    return ":" + ahptools_env;
  }

  public void close() {
    if (uow != null) uow.close();
  }

  public void saveAndClose() throws PersistenceException {
    if (uow != null) uow.commitAndClose();
  }
}
