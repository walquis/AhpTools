package com.site.common.remote;

import com.site.common.util.*;
import com.site.common.util.ReadableString;
import com.urbancode.anthill3.domain.reporting.*;

public abstract class RemoteReport {

  public String getReadableName() {
    return new ReadableString(this.getClass().getSimpleName()).titleFormat();
  }

  public abstract String getDescription();

  protected abstract ReportMetaData metadataScript() throws Exception;

  /**
   * Even though we could access the metadata directly, the AHP server interface
   * expects this to be passed into the script as a parameter.
   *
   * @param metaData - Metadata that the AHP server interface expects;
   * @return Output from the server
   * @throws Exception
   */
  protected abstract ReportOutput reportScript(ReportMetaData metaData) throws Exception;

  public Report createReportFromSource(String sourceBase) throws Exception {
    String fileName = sourceBase + this.getClass().getSimpleName() + ".java";
    ParsedJavaSource source = new ParsedJavaSource(fileName);

    Report newReport = new Report();
    newReport.setName(this.getReadableName());
    newReport.setDescription(this.getDescription());
    newReport.setPubliclyAvailable(false);
    newReport.setMetaDataScript(source.metaDataScript());
    newReport.setReportScript(source.reportScript());
    return newReport;
  }
}
