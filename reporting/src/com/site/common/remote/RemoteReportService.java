package com.site.common.remote;

import com.urbancode.anthill3.domain.reporting.Report;
import com.urbancode.anthill3.domain.reporting.ReportFactory;
import com.urbancode.anthill3.domain.reporting.ReportOutput;

import java.util.*;

public class RemoteReportService {

  private AnthillConnection connection = new AnthillConnection();
  private ReportCache cache = ReportCache.getInstance();

  public ReportOutput run(RemoteReport report) throws Exception {
    connection.open();
    ReportOutput output = report.reportScript(report.metadataScript());
    connection.close();
    return output;
  }

  public List<Report> getReports() throws Exception {
    connection.open();
    Report[] reports = ReportFactory.getInstance().restoreAll();
    connection.close();
    cache.addAll(reports);
    return Arrays.asList(reports);
  }

  public boolean deleteReport(String reportName) throws Exception {
    Report report = reportFromCache(reportName);
    if (report == null) {
      throw new RuntimeException("'" + reportName + "' doesn't exist on the server.");
    }

    connection.open();
    report.delete();
    connection.saveAndClose();

    cache.remove(reportName);
    return true;
  }

  public Report createReport(RemoteReport remoteReport, String pathToSource) throws Exception {
    Report report = reportFromCache(remoteReport.getReadableName());
    if (report != null) {
      throw new RuntimeException("'" + remoteReport.getReadableName() + "' already exists on the server.");
    }
    Report newReport = remoteReport.createReportFromSource(pathToSource);

    connection.open();
    newReport.store();
    connection.saveAndClose();

    cache.put(newReport.getName(), newReport);
    return newReport;
  }

  private Report reportFromCache(String reportName) throws Exception {
    if (cache.isEmpty()) getReports();
    return cache.get(reportName);
  }
}
