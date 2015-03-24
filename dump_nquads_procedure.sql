create procedure dump_nquads (in dir varchar := 'dumps', in start_from int := 1, in file_length_limit integer := 100000000, in comp int := 1)
{
  declare inx, ses_len int;
  declare file_name varchar;
  declare env, ses any;

  inx := start_from;
  set isolation = 'uncommitted';
  env := vector (0,0,0);
  ses := string_output (10000000);
  for (select * from (sparql define input:storage "" select ?s ?p ?o ?g { graph ?g { ?s ?p ?o } . filter ( ?g != virtrdf: ) } ) as sub option (loop)) do
    {
      declare exit handler for sqlstate '22023' 
      {
        goto next;
	};
      http_nquad (env, "s", "p", "o", "g", ses);
      ses_len := length (ses);
      if (ses_len >= file_length_limit)
      {
        file_name := sprintf ('%s/output%06d.nq', dir, inx);
	  string_to_file (file_name, ses, -2);
	    if (comp)
	        {
		      gz_compress_file (file_name, file_name||'.gz');
		            file_delete (file_name);
			        }
				  inx := inx + 1;
				    env := vector (0,0,0);
				      ses := string_output (10000000);
				      }
      next:;
    }
  if (length (ses))
    {
      file_name := sprintf ('%s/output%06d.nq', dir, inx);
      string_to_file (file_name, ses, -2);
      if (comp)
      {
        gz_compress_file (file_name, file_name||'.gz');
	  file_delete (file_name);
	  }
      inx := inx + 1;
      env := vector (0,0,0);
    }
}
;
