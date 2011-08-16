package com.site.common.util;

import org.junit.Test;
import static org.junit.Assert.*;
import static org.hamcrest.core.IsNull.notNullValue;
import com.site.common.remote.RemoteReportTestHelper;

public class ParsedJavaSourceTest {
  private String fileName = RemoteReportTestHelper.TEST_SOURCE_DIR + "SampleReport.java";

  @Test
  public void shouldRetrieveMetaDataScript() throws Exception {
    ParsedJavaSource source = new ParsedJavaSource(fileName);
    assertThat(source.metaDataScript(), notNullValue());
    assertTrue(source.metaDataScript().contains("import"));
    assertTrue(source.metaDataScript().contains("return"));
//    System.out.println(source.metaDataScript());
  }

  @Test
  public void shouldRetrieveReportScript() throws Exception {
    ParsedJavaSource source = new ParsedJavaSource(fileName);
    assertThat(source.reportScript(), notNullValue());
    assertTrue(source.reportScript().contains("import"));
    assertTrue(source.reportScript().contains("return"));
//    System.out.println(source.reportScript());
  }
}
