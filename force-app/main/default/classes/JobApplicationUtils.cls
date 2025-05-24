public with sharing class JobApplicationUtils {

    public class SalaryParseResult {
        public String display;
        public Decimal numeric;
    }

    public static String cleanDescription(String description) {
        if (String.isBlank(description)) {
            return ''; 
        }

        return description
            .replaceAll('<[^>]+>', '')       // Remove HTML tags
            .replaceAll('&nbsp;', ' ')       // Replace HTML space
            .replaceAll('\\s+', ' ')         // Normalize whitespace
            .trim();
    }

    public static String extractSalaryFromText(String description) {
        if (String.isBlank(description)) {
            return null;  
        } 

        String cleanDesc = cleanDescription(description);

        // Match $17,600 or $88.00 patterns
        Pattern salaryPattern = Pattern.compile('\\$[\\d,.kK]+');
        Matcher matcher = salaryPattern.matcher(cleanDesc);

        if (matcher.find()) {
            return matcher.group(0);
        }

        return null;
    }    

    public static SalaryParseResult parseSalaryFromJob(Map<String, Object> job) {
        SalaryParseResult result = new SalaryParseResult();

        String salaryRaw = (String) job.get('salary');
        if (!String.isBlank(salaryRaw)) {
            result.display = salaryRaw;

            String numericPart = salaryRaw.replaceAll('[^\\d.,]', '').replace(',', '');
            try {
                result.numeric = Decimal.valueOf(numericPart);
            } catch (Exception e) {
                System.debug('Could not parse numeric portion of salary: ' + numericPart);
            }

            return result;
        }

        if (job.containsKey('salary_val1') && job.containsKey('salary_val2')) {
            try {
                Decimal minVal = Decimal.valueOf(String.valueOf(job.get('salary_val1')));
                Decimal maxVal = Decimal.valueOf(String.valueOf(job.get('salary_val2')));
                result.numeric = (minVal + maxVal) / 2;
                result.display = '$' + String.valueOf(minVal.setScale(0)) + ' - $' + String.valueOf(maxVal.setScale(0));
                return result;
            } catch (Exception e) {
                System.debug('Failed to parse salary_val1/2: ' + e.getMessage());
            }
        }

        if (job.containsKey('min') && job.containsKey('max')) {
            try {
                Decimal minVal = Decimal.valueOf(String.valueOf(job.get('min')));
                Decimal maxVal = Decimal.valueOf(String.valueOf(job.get('max')));
                result.numeric = (minVal + maxVal) / 2;
                result.display = 'From ' + minVal + ' to ' + maxVal;
                return result;
            } catch (Exception e) {
                System.debug('Failed to parse min/max salary: ' + e.getMessage());
            }
        }

        String snippet = (String) job.get('snippet');
        String fallback = extractSalaryFromText(snippet);
        if (!String.isBlank(fallback)) {
            result.display = fallback;

            String cleaned = fallback.replaceAll('[^\\d.,]', '').replace(',', '');
            try {
                result.numeric = Decimal.valueOf(cleaned);
            } catch (Exception e) {
                System.debug('Failed to parse salary from snippet: ' + cleaned);
            }
        }
        return result;
    }
}

