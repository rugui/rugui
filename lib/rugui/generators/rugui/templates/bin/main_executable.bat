# ATTENTION: This is just a sample, it it not tested at all!

@set APPLICATION_ROOT=<%= destination_root %>
@set APPLICATION_EXECUTABLE=%APPLICATION_ROOT%\app\main.rb
@set RUBY_EXECUTABLE=c:\ruby\1.8\ruby
@set RUGUI_ENV=production

"%RUBY_EXECUTABLE%" "%APPLICATION_EXECUTABLE%" %1 %2 %3 %4 %5 %6 %7
