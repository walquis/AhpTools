package com.site.common.remote;

import com.urbancode.anthill3.domain.reporting.*;
import static org.junit.Assert.assertThat;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.core.IsNot.not;

import java.util.List;

public class RemoteReportTestHelper {
  public static final String TEST_SOURCE_DIR = "test/com/site/common/remote/";
  public static final String SOURCE_DIR = "reporting/src/com/site/anthill/reports/";
  public static final RemoteReportService REPORT_SERVICE = new RemoteReportService();

  public static ReportOutput runAndTest(RemoteReport report) throws Exception {
    ReportOutput output = REPORT_SERVICE.run(report);
    validate(output);
    preview(output);
    return output;
  }

  private static void validate(ReportOutput output) {
    assertThat(output.getColumnCount(), is(not(0)));
    //assertThat(output.getRowArray().length, is(not(0)));
  }

  private static void preview(ReportOutput output) {
    String[] columns = output.getColumnArray();
    ReportRow[] rows = output.getRowArray();
    for (ReportRow row : rows) {
      for (String column : columns) {
        System.out.print(clean(row.getColumnValue(column)));
      }
      System.out.println();
    }
  }

  private static String clean(String value) {
    return value == null ? "  " : value;
  }

  public static void print(List<Report> reports) {
    System.out.println("Remote Reports:");
    for (Report report : reports) {
      System.out.println(report.getName());
    }
  }
}
