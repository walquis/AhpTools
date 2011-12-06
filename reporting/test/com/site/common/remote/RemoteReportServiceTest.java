package com.site.common.remote;

import org.junit.Test;
import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.core.IsNot.not;
import com.urbancode.anthill3.domain.reporting.Report;
import com.urbancode.anthill3.domain.reporting.ReportOutput;
import com.site.anthill.reports.*;

import java.util.List;
import java.util.regex.Pattern;

public class RemoteReportServiceTest {
  private RemoteReportService reportService = RemoteReportTestHelper.REPORT_SERVICE;
  private String SOURCE_DIR = RemoteReportTestHelper.SOURCE_DIR;
  // Substitute the impl with whatever report you're working on until we update the AhpTools command line tool.
//  private RemoteReport report = new ProjectListReport();
//  private RemoteReport report = new BuildLivesInEnvironmentReport();
//  private RemoteReport report = new PerProjectDeploymentReport();
//  private RemoteReport report = new WhatsBeenDeployed();
//  private RemoteReport report = new WhatsBeenDeployedWithSuccessStatus();
//  private RemoteReport report = new ArtifactSets();
//  private RemoteReport report = new PropertiesForAgentsInChosenEnvironment();
//  private RemoteReport report = new AgentsForWhomParentJobSucceeded();
//  private RemoteReport report = new AgentsMissingFromProdAndNonProdEnvironments();
//  private RemoteReport report = new AgentsInBothProdAndNonProdEnvironments();
//  private RemoteReport report = new ProjectListReport();
//  private RemoteReport report = new SampleReport();
//  private RemoteReport report = new TeamCityIntegrationReport();
  private RemoteReport report = new AgentsInEnvironmentByKeyword();

  @Test
  public void deleteReportFromServer() throws Exception {
    assertTrue(reportService.deleteReport(report.getReadableName()));
  }

  @Test
  public void createReportOnServer() throws Exception {
    Report newReport = reportService.createReport(report, SOURCE_DIR);
    assertThat(newReport, notNullValue());
    assertThat(newReport.getName(), is(report.getReadableName()));
    assertThat(newReport.getDescription(), is(report.getDescription()));
    try {
      reportService.createReport(report, SOURCE_DIR);
      fail();
    } catch (Exception ex) {
      // should throw exception when we attempt to create a duplicate report.
    }
  }

  @Test
  public void shouldRunReport() throws Exception {
    ReportOutput output = RemoteReportTestHelper.runAndTest(report);
  }

  @Test
  public void shouldReturnAllReportsFromServer() throws Exception {
    List<Report> reports = reportService.getReports();
    assertThat(reports.size(), is(not(0)));
    RemoteReportTestHelper.print(reports);
  }

  @Test(expected=RuntimeException.class)
  public void shouldBombIfReportDoesNotExistOnServer() throws Exception {
    reportService.deleteReport("bunk");
  }

  @Test
  public void testRegex() {
      String k = "Windows 2003";
      System.err.println("Linux OS pre-condition script: k = " + k);
      boolean res = Pattern.compile("indows.*").matcher(k).find();
      System.err.println("Linux OS pre-condition script: result = " + Boolean.toString(res));
      assertTrue(res);

  }

}
