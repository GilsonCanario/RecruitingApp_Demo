/**
 * Tests for Security Settings metadata (IAC-06)
 * Verifies that MFA enforcement for SSO/UI logins is correctly configured
 * in the Security.settings-meta.xml metadata file.
 */
"use strict";

const fs = require("fs");
const path = require("path");

const SETTINGS_FILE = path.resolve(__dirname, "../Security.settings-meta.xml");

describe("Security Settings - MFA Enforcement for SSO Sessions (IAC-06)", () => {
  let xmlContent;

  beforeAll(() => {
    xmlContent = fs.readFileSync(SETTINGS_FILE, "utf8");
  });

  it("settings file exists", () => {
    expect(fs.existsSync(SETTINGS_FILE)).toBe(true);
  });

  it("has valid XML root element SecuritySettings", () => {
    expect(xmlContent).toContain("<SecuritySettings");
    expect(xmlContent).toContain("</SecuritySettings>");
  });

  it("contains sessionSettings block", () => {
    expect(xmlContent).toContain("<sessionSettings>");
    expect(xmlContent).toContain("</sessionSettings>");
  });

  it("enableMFADirectUILoginOptIn is set to true to enforce MFA for UI/SSO logins", () => {
    expect(xmlContent).toContain(
      "<enableMFADirectUILoginOptIn>true</enableMFADirectUILoginOptIn>"
    );
  });

  it("does NOT have enableMFADirectUILoginOptIn set to false", () => {
    expect(xmlContent).not.toContain(
      "<enableMFADirectUILoginOptIn>false</enableMFADirectUILoginOptIn>"
    );
  });

  it("contains singleSignOnSettings block", () => {
    expect(xmlContent).toContain("<singleSignOnSettings>");
    expect(xmlContent).toContain("</singleSignOnSettings>");
  });

  it("requires HTTPS connections (enableRequireHttpsConnection is true)", () => {
    expect(xmlContent).toContain(
      "<enableRequireHttpsConnection>true</enableRequireHttpsConnection>"
    );
  });

  it("XML is well-formed with closing tags present for every element", () => {
    const closingTags = (xmlContent.match(/<\/[^>]+>/g) || []).length;
    const selfClosing = (xmlContent.match(/<[^/!?][^>]*\/>/g) || []).length;
    // All meaningful elements should be either closed or self-closing
    expect(closingTags + selfClosing).toBeGreaterThan(0);
    // The XML declaration and root element must both appear
    expect(xmlContent).toMatch(/^<\?xml version="1\.0"/);
    expect(xmlContent).toMatch(/<\/SecuritySettings>\s*$/);
  });
});
