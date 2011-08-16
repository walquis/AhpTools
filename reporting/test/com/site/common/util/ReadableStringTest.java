package com.site.common.util;

import static org.junit.Assert.assertEquals;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.util.Arrays;
import java.util.Collection;

@RunWith(Parameterized.class)
public class ReadableStringTest {

    @Parameterized.Parameters
    public static Collection regExValues() {
     return Arrays.asList(new String[][] {
         {"camel", "Camel"},
         {"Camel", "Camel"},
         {"camelCase", "Camel case"},
         {"CamelCase", "Camel case"},
         {"doubleCamelCase", "Double camel case"},
         {"DoubleCamelCase", "Double camel case"},
         {"somethingRandomInTheHouse", "Something random in the house"},
         {"aTLA", "A TLA"},
         {"aTLAAndSomeMore", "A TLA and some more"},
         {"NOTCAMELCASE", "NOTCAMELCASE"},
         {"Certainly not camel case", "Certainly not camel case"}
      });
    }

    String input;
    String expectedOutcome;

    public ReadableStringTest(String input, String expectedOutcome) {
        this.input = input;
        this.expectedOutcome = expectedOutcome;
    }

    @Test
    public void humaniseShouldRenderCamelCaseAsHumanReadable() {
        assertEquals(expectedOutcome, new ReadableString(input).humanReadableFormat());
    }

    @Test
    public void shouldRenderCamelCaseAsTitle() {
      assertEquals("Something Random In The House", new ReadableString("somethingRandomInTheHouse").titleFormat());
      assertEquals("Certainly Not Camel Case", new ReadableString("Certainly not camel case").titleFormat());
    }
}
