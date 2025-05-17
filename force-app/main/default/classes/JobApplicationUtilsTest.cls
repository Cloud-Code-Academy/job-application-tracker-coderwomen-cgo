@isTest
private class JobApplicationUtilsTest {

    @isTest
    static void testCleanDescription() {
        String input = '<div>  Salary&nbsp;is <strong>$100,000</strong></div>';
        String result = JobApplicationUtils.cleanDescription(input);
        System.assertEquals('Salary is $100,000', result, 'HTML and whitespace cleaned');
    }

    @isTest
    static void testExtractSalaryFromText_withValidSalary() {
        String input = 'This role pays up to $88,740.00 annually.';
        String extracted = JobApplicationUtils.extractSalaryFromText(input);
        System.assertEquals('$88,740.00', extracted, 'Salary extracted from text');
    }

    @isTest
    static void testExtractSalaryFromText_withNoSalary() {
        String input = 'No salary listed here.';
        String extracted = JobApplicationUtils.extractSalaryFromText(input);
        System.assertEquals(null, extracted, 'No salary match returns null');
    }

    @isTest
    static void testParseSalaryFromJob_usingSalaryField() {
        Map<String, Object> job = new Map<String, Object>{
            'salary' => '$95,000 USD'
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);
        System.assertEquals('$95,000 USD', result.display, 'Display matches salary field');
        System.assertEquals(95000, result.numeric, 'Parsed numeric value from salary string');
    }

    @isTest
    static void testParseSalaryFromJob_usingSalaryVal1Val2() {
        Map<String, Object> job = new Map<String, Object>{
            'salary_val1' => 80000,
            'salary_val2' => 120000
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);
        System.assertEquals('$80000 - $120000', result.display, 'Display matches range');
        System.assertEquals(100000, result.numeric, 'Average of min and max parsed');
    }

    @isTest
    static void testParseSalaryFromJob_usingMinMaxFallback() {
        Map<String, Object> job = new Map<String, Object>{
            'min' => 50000,
            'max' => 70000
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);
        System.assertEquals('From 50000 to 70000', result.display, 'Min/max fallback used');
        System.assertEquals(60000, result.numeric, 'Min/max average calculated');
    }

    @isTest
    static void testParseSalaryFromJob_usingSnippetFallback() {
        Map<String, Object> job = new Map<String, Object>{
            'snippet' => 'Amazing opportunity, earn $42,500!'
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);
        System.assertEquals('$42,500', result.display, 'Salary extracted from snippet');
        System.assertEquals(42500, result.numeric, 'Parsed from snippet text');
    }

    @isTest
    static void testParseSalaryFromJob_returnsEmptyResultWhenNoMatch() {
        Map<String, Object> job = new Map<String, Object>{
            'title' => 'No salary here',
            'snippet' => 'Compensation not disclosed'
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);
        System.assertEquals(null, result.display, 'No salary found = no display');
        System.assertEquals(null, result.numeric, 'No salary found = no numeric');
    }

    @isTest
    static void testCleanDescription_withBlankInput() {
        String result1 = JobApplicationUtils.cleanDescription(null);
        System.assertEquals('', result1, 'Null input should return empty string');

        String result2 = JobApplicationUtils.cleanDescription('   ');
        System.assertEquals('', result2, 'Whitespace-only input should return empty string');
    }

    @isTest
    static void testExtractSalaryFromText_withBlankInput() {
        String result1 = JobApplicationUtils.extractSalaryFromText(null);
        System.assertEquals(null, result1, 'Null input should return null');

        String result2 = JobApplicationUtils.extractSalaryFromText('   ');
        System.assertEquals(null, result2, 'Whitespace-only input should return null');
    }

        @isTest
    static void testParseSalaryFromJob_invalidSalaryThrowsException() {
        Map<String, Object> job = new Map<String, Object>{
            'salary' => '$ninety thousand dollars'
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);

        System.assertEquals('$ninety thousand dollars', result.display, 'Display should still be set');
        System.assertEquals(null, result.numeric, 'Numeric value should be null due to parse error');
    }

    @isTest
    static void testParseSalaryFromJob_invalidSalaryVal1Val2ThrowsException() {
        Map<String, Object> job = new Map<String, Object>{
            'salary_val1' => 'eightyK',
            'salary_val2' => 'onehundredK'
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);

        System.assertEquals(null, result.display, 'Display should be null due to parse error');
        System.assertEquals(null, result.numeric, 'Numeric value should be null due to parse error');
    }

    @isTest
    static void testParseSalaryFromJob_invalidSnippetSalaryThrowsException() {
        Map<String, Object> job = new Map<String, Object>{
            'snippet' => 'Expected salary: $k'
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);

        System.assertEquals('$k', result.display, 'Display should show extracted snippet salary');
        System.assertEquals(null, result.numeric, 'Should be null due to parse error from empty cleaned value');
    }
    @isTest
    static void testParseSalaryFromJob_invalidMinMaxThrowsException() {
        Map<String, Object> job = new Map<String, Object>{
            'min' => 'low',
            'max' => 'high'
        };

        JobApplicationUtils.SalaryParseResult result = JobApplicationUtils.parseSalaryFromJob(job);

        System.assertEquals(null, result.display, 'Display should be null due to parse error');
        System.assertEquals(null, result.numeric, 'Numeric value should be null due to parse error');
    }
}
