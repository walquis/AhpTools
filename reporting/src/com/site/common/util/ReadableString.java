package com.site.common.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

interface CapitalizationStrategy {
  public void capitalize(String word);
}

public class ReadableString {

  private final CapitalizationStrategy LOWER_CASE = new CapitalizationStrategy() {
    public void capitalize(String word) {
      appendWordLowerCase(word);
    }
  };
  private final CapitalizationStrategy UPPER_CASE = new CapitalizationStrategy() {
    public void capitalize(String word) {
      appendWordUpperCase(word);
    }
  };

  private static final String SINGLE_CAPITAL_PATTERN = "^[A-Z]$";
  private static final String CAMEL_CASE_PATTERN = "([A-Z]|[a-z])[a-z]*";

  private String humanisedString = "";
  private String acronym = "";
  private final String input;

  public ReadableString(String input) {
    this.input = input;
  }

  public String humanReadableFormat() {
    return humanizedString(LOWER_CASE);
  }

  public String titleFormat() {
    return humanizedString(UPPER_CASE);
  }

  private String humanizedString(CapitalizationStrategy caps) {
    Matcher wordMatcher = Pattern.compile(CAMEL_CASE_PATTERN).matcher(input);
    while (wordMatcher.find()) {
      String word = wordMatcher.group();
      if (word.matches(SINGLE_CAPITAL_PATTERN)) {
        acronym += word;
      } else {
        appendAcronymIfThereIsOne();
        caps.capitalize(word);
      }
    }
    appendAcronymIfThereIsOne();
    return humanisedString.length() > 0 ? humanisedString : input;
  }

  private void appendWordLowerCase(String word) {
    humanisedString += firstWord() ? capitaliseFirstLetter(word) : " " + word.toLowerCase();
  }

  private void appendWordUpperCase(String word) {
    humanisedString += firstWord() ? capitaliseFirstLetter(word) : " " + capitaliseFirstLetter(word);
  }

  private void appendAcronymIfThereIsOne() {
    if (acronym.length() > 0) {
      humanisedString += firstWord() ? acronym : " " + acronym;
      acronym = "";
    }
  }

  private boolean firstWord() {
    return humanisedString.length() == 0;
  }

  private String capitaliseFirstLetter(String str) {
    return str.substring(0, 1).toUpperCase() + str.substring(1);
  }
}
