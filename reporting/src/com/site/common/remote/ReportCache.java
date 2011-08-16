package com.site.common.remote;

import com.urbancode.anthill3.domain.reporting.Report;

import java.util.HashMap;

public class ReportCache {
  private final HashMap<String, Report> cache = new HashMap<String, Report>();
  private static ReportCache instance;

  public static ReportCache getInstance() {
    if (instance == null) {
      instance = new ReportCache();
    }
    return instance;
  }

  public void addAll(Report[] reports) {
    for (Report report : reports) {
      cache.put(report.getName(), report);
    }
  }

  public boolean isEmpty() {
    return cache.isEmpty();
  }

  public void remove(String reportName) {
    cache.remove(reportName);
  }

  public Report get(String reportName) {
    return cache.get(reportName);
  }

  public void put(String name, Report report) {
    cache.put(name, report);
  }
}
