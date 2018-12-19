package com.ps.e2e.jacoco.testcoverageexample;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.test.context.junit4.SpringRunner;

import static org.assertj.core.api.Assertions.assertThat;

@RunWith(SpringRunner.class)
public class TestCoverageExampleApplicationTests {

    private TestRestTemplate testRestTemplate = new TestRestTemplate();

    @Test
    public void anotherBranchTest() {
        //given
        String appUrl =  System.getProperty("app.url");
        int parameter = Integer.parseInt(System.getProperty("parameter"));

        //when
        Integer result = testRestTemplate.getForObject(
                appUrl + "/test?parameter=" + parameter, Integer.class);

        //then
        assertThat(result).isEqualTo(3);
    }

}
