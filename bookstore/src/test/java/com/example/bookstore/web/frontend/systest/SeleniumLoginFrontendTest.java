package com.example.bookstore.web.frontend.systest;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.openqa.selenium.*;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.Wait;
import org.openqa.selenium.support.ui.WebDriverWait;

public class SeleniumLoginFrontendTest {

	private WebDriver browser;
	
	private Properties prop = new Properties();

	public void waitForPageLoaded(WebDriver driver) {

		ExpectedCondition<Boolean> expectation = new ExpectedCondition<Boolean>() {
			public Boolean apply(WebDriver driver) {
				return ((JavascriptExecutor) driver).executeScript(
						"return document.readyState").equals("complete");
			}
		};

		Wait<WebDriver> wait = new WebDriverWait(driver, 30);
		try {
			wait.until(expectation);
		} catch (Throwable error) {
			assertEquals("Timeout waiting for Page Load Request to complete.",
					false, true);
		}
	}

	@Before
	public void setup() throws IOException {
		ClassLoader loader = Thread.currentThread().getContextClassLoader();           
		InputStream stream = loader.getResourceAsStream("selenium.properties");
		prop.load(stream);
		
		browser = new FirefoxDriver();
	}

	@Test
	public void startTest() {
		browser.get(prop.getProperty("url"));
		waitForPageLoaded(browser);

		browser.findElement(By.id("login")).click();
		waitForPageLoaded(browser);

		// Will throw exception if elements not found
		browser.findElement(By.id("username")).sendKeys("jd");
		browser.findElement(By.id("password")).sendKeys("secret");

		browser.findElement(By.id("loginButton")).click();
		waitForPageLoaded(browser);
		browser.findElement(By.id("account")).click();
		waitForPageLoaded(browser);

		assertEquals("John", browser.findElement(By.id("firstName"))
				.getAttribute("value"));
	}

	@After
	public void tearDown() {
		browser.close();
	}
}
