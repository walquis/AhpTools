package com.site.anthill.reports;

import com.urbancode.anthill3.domain.reporting.ReportMetaData;
import com.urbancode.anthill3.domain.reporting.ReportOutput;
import com.urbancode.anthill3.domain.reporting.ReportRow;
import com.site.common.remote.RemoteReport;

public class SampleReport extends RemoteReport {
  public String getDescription() {
    return "Created by AhpTools during testing - delete";
  }

  protected ReportMetaData metadataScript() {
    ReportMetaData rmd = new ReportMetaData();
    rmd.addColumn("Sample");
    return rmd;
  }

  protected ReportOutput reportScript(ReportMetaData metaData) throws Exception {
    ReportOutput output = new ReportOutput(metaData);
    ReportRow row = new ReportRow(output, null);
    row.setColumnValue("Sample", "Sample row");
    output.addRow(row);
    return output;
  }
}
