# frozen_string_literal: true

require 'table_print'
require 'terminal-table'

module ConsoleBuddy
  module Report
    # Example Usage:
    # table_print User.all, "username"
    def table_print(data, options = {})
      puts ::TablePrint::Printer.table_print(data, options)
    end
    alias print_data table_print

    # Example Usage:
    # table_for([["foo", "bar"], ["baz", "qux"]], ["col1", "col2"])
    def table_for(rows, headers = [])
      table = ::Terminal::Table.new(headings: headers, rows: rows)
      puts table
    end
  end
end
