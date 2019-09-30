function sl_stoppool()

sl_sendbatch('sl_stopslave');
system('cd ~/.matlabslaves; rm *');

end