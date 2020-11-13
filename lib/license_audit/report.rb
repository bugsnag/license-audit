module LicenseAudit
  class Report
    
    REPORT_FILENAME = 'reports/index.html'

    PLACEHOLDER_TABLE_BOTTOM = "<!-- TABLE_BOTTOM -->"
    PLACEHOLDER_COMPLETED_TIME_START = "<!-- COMPLETED_TIME -->"
    PLACEHOLDER_COMPLETED_TIME_END = "<!-- COMPLETED_TIME_END -->"
    PLACEHOLDER_APP_START = "<!-- APP_RESULT:%s -->"
    PLACEHOLDER_APP_END = "<!-- APP_RESULT_END:%s -->"
    
    class << self

      def create()

        report_text = File.read("./summary_file_header.html")
        report_text += "<h1>Bugsnag Notifier Repository License Audit</h1>\n"
        report_text += "<h3>Reports</h3>\n<p>Started at: #{Time.new}</p>\n"
        report_text += "<table class='table'>\n<thead>\n<th>Repository</th>\n<th>Build</th>\n<th>Audit</th>\n</thead>\n<tbody>\n"
        report_text += PLACEHOLDER_TABLE_BOTTOM
        report_text += "</tbody>\n</table>\n"
        report_text += "<p>Completed at: #{PLACEHOLDER_COMPLETED_TIME_START}#{Time.new}#{PLACEHOLDER_COMPLETED_TIME_END}</p>\n"
        report_text += File.read("./summary_file_footer.html")
        
        writeToFile(report_text, false)
        
      end

      def addAppRun(app, branch, working_dir, build_succeeded, audit_succeeded)

        output_text = PLACEHOLDER_APP_START % [app.report_name(branch, working_dir)]
        output_text += "<tr>\n<td>\n<a href=\"https://github.com/#{app.repo}/tree/#{branch}/#{working_dir}\">#{app.report_readable_name(branch, working_dir)}</a> "
        output_text += "[<a href=\"#{File.join(app.location, working_dir)}/doc/dependency_decisions.yml\">decision file</a>]\n</td>\n"
        output_text += "<td>\n<a href=\"../build/#{app.report_name(branch, working_dir)}.txt\">"
        
        if (build_succeeded)
          output_text += "<span class=\"badge badge-success\">&#x2713;</span></a>\n</td>\n"
          if (audit_succeeded)
            output_text += "<td>\n<a href=\"../reports/#{app.report_name(branch, working_dir)}.html\"><span class=\"badge badge-success\">&#x2713;</span>\n</td>\n"
          else
            output_text += "<td>\n<a href=\"../reports/#{app.report_name(branch, working_dir)}.html\"><span class=\"badge badge-important\">&#x2717;</span>\n</td>\n"
          end
        else
          output_text += "<span class=\"badge badge-important\">&#x2717;</span></a>\n</td>\n"
          output_text += "<td>\n</td>\n"
        end

        output_text += "</tr>\n"
        output_text += PLACEHOLDER_APP_END % [app.report_name(branch, working_dir)]
        output_text += "\n"

        report_text = readFromFile()

        if report_text.include? PLACEHOLDER_APP_START % [app.report_name(branch, working_dir)]
          report_text = report_text.sub(/#{PLACEHOLDER_APP_START % [app.report_name(branch, working_dir)]}.*#{PLACEHOLDER_APP_END % [app.report_name(branch, working_dir)]}/m, output_text)
        else
          report_text = report_text.sub(/#{PLACEHOLDER_TABLE_BOTTOM}/, output_text + PLACEHOLDER_TABLE_BOTTOM)
        end
        report_text = report_text.sub(/#{PLACEHOLDER_COMPLETED_TIME_START}.*#{PLACEHOLDER_COMPLETED_TIME_END}/,
                                      PLACEHOLDER_COMPLETED_TIME_START + Time.new.to_s + PLACEHOLDER_COMPLETED_TIME_END)
        
        writeToFile(report_text)

      end

      def readFromFile()
        File.read(REPORT_FILENAME)
      end

      def writeToFile(report_text, overwrite = true)
        Dir.mkdir('reports') unless Dir.exist?('reports')
        if (not File.exist?(REPORT_FILENAME)) || overwrite
          summary_file = File.open('reports/index.html', "w")
          summary_file.puts(report_text)
          summary_file.close
        end
      end

    end
  end
end