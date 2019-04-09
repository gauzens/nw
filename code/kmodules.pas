unit kmodules;

interface

procedure simul_mod(g : integer; tf,ti,ts,eps : extended);

implementation

uses SysUtils,kglobvar,kutil,kgroup,kmath,ksyntax;

var energy : extended;
    gp_sav,gp_saved,gp_best : groups;

procedure Egroup_modul(g,gp : integer);
begin
  with group[gp],graphes[g] do
    ener := inlinks/nb_arcs - sqr((out_degree+in_degree)/(2.0*nb_arcs));
end;

procedure init_energies(g : integer);
var i : integer;
begin
  energy := 0.0;
  for i := 1 to nb_groups do
    begin
      Egroup_modul(g,i);
      energy := energy + group[i].ener;
    end;
end;

procedure info_groupe(g : integer);
var x,y,k,j :integer;
begin
with graphes[g] do
begin
  init_mat_groupe;
  for k := 1 to nb_groups do with group[k] do
  begin
    inlinks := 0;
    outlinks := 0;
    out_degree := 0;
    in_degree := 0;
  end;

  for k := 1 to nb_groups do with group[k] do
  begin
    for j:=1 to nb_som do //sp j du groupe k
    begin
      x:=sommets[j]; //x: pos ds ggg de la j sp du gpe k
      y:=ggg[x].succ;  // y est le succ de l'espèce x
      while ( y <> 0 ) do with lis[y] do
        begin
          mgr_[k,ggg_gpe[car]]:=mgr_[k,ggg_gpe[car]]+1;
          out_degree:=out_degree+1;
          group[ggg_gpe[car]].in_degree:=group[ggg_gpe[car]].in_degree+1;
          if  ggg_gpe[x]=ggg_gpe[car] then
          begin
            group[k].inlinks:=group[k].inlinks+1;
          end
          else
          begin
            group[k].outlinks:=group[k].outlinks+1;
            group[ggg_gpe[car]].outlinks:=group[ggg_gpe[car]].outlinks+1;
          end;
           y:=cdr;
        end;
    end;
   end;
end;
end;

procedure calcul_groupe(g : integer);
var x,y,k,j,u : integer;
begin
  with graphes[g] do
    begin
      init_mat_groupe;
      for k := 1 to nb_groups do with group[k] do
        begin
          inlinks := 0;
          outlinks := 0;
          out_degree := 0;
          in_degree := 0;
        end;
      for k := 1 to nb_groups do with group[k] do
        for j := 1 to nb_som do //sp j du groupe k
          begin
            x := sommets[j]; //x: pos ds ggg de la j sp du gpe k
            y := ggg[x].succ;  // y est le succ de l'espèce x
            while ( y <> 0 ) do with lis[y] do
              begin
                u := ggg_gpe[car];
                out_degree := out_degree + 1;
                group[u].in_degree := group[u].in_degree + 1;
                if ( ggg_gpe[x] = u ) then
                  group[k].inlinks := group[k].inlinks + 1
                else
                  begin
                    group[k].outlinks := group[k].outlinks + 1;
                    group[u].outlinks := group[u].outlinks + 1;
                  end;
                y := cdr;
              end;
          end;
    end;
end;

procedure maj_energy(init,init1,fin,fin1 : extended);
begin //maj de l'E, quand on a change 2 groupes
  energy := energy - init - init1 + fin + fin1;
end;

procedure simul_mod(g : integer; tf,ti,ts,eps : extended);
var i,j,k,x,y,count,cycle1,cycle2,sp,grA,grB,noeud,ngroup_sav,ngroup_best,tour,g1,trouve,to_limit : integer;
    energy_sav,energy_best,energy_ant, T,role,e,e1 : extended;
    connex : boolean; //presence de plusieurs comp connexes
const limit = 20;

procedure metropolis; //accepte ou non les changements faits
var i : integer;
begin
  if ( (energy > energy_sav) or (exp((energy-energy_sav)/t) > rand(1.0)) ) then
    begin  // on sauvegarde les changements
      energy_sav := energy;
      for i := 1 to nb_groups do gp_sav[i] := group[i];
      ngroup_sav := nb_groups;
    end
  else
    begin        //sinon, on repart de energy sav
      for i := 1 to ngroup_sav do group[i] := gp_sav[i];
      nb_groups := ngroup_sav;
      reactualise_gpes;
      energy := energy_sav;
    end;
end;

procedure sous_simul(g,grA,grB : integer);
var x,y,ngroup_saved,i : integer;
    tsplit,energy_saved : extended;
begin
with graphes[g] do
begin
  tsplit := ti;
  energy_saved := energy;
  for i := 1 to nb_groups do gp_saved[i] := group[i];
  ngroup_saved := nb_groups;
  while tsplit >= t do
  begin
    e := group[grA].ener;
    e1 := group[grB].ener;
    for x := 1 to group[grA].nb_som + group[grB].nb_som do
    begin
      if group[grA].nb_som > group[grB].nb_som then
           begin
             y := trunc(rand(group[grA].nb_som))+1;
             deplace_sp(y,grA,grB);
           end
           else
           begin
             y := trunc(rand(group[grB].nb_som)) + 1;
             deplace_sp(y,grB,grA);
           end;
    end;
    calcul_groupe(g);
    egroup_modul(g,grA);
    egroup_modul(g,grB);
    (*energy:=energy - e - e1 + group[grA].ener + group[grB].ener;*)
    maj_energy(e,e1,group[grA].ener,group[grB].ener);
    //sous metropolis:
    if ((energy > energy_saved) or (rand(1) < exp((energy-energy_saved)/tsplit))) then
      begin
        for i := 1 to nb_groups do gp_saved[i] :=group[i];
        ngroup_saved :=nb_groups;
        energy_saved :=energy;
      end
    else
      begin
        for i := 1 to ngroup_saved do group[i] :=gp_saved[i];
        nb_groups := ngroup_saved;
        energy := energy_saved;
        reactualise_gpes;
      end;
  tsplit := tsplit*ts;
  end;
end;
end;

begin
////////////////////////////////////////////////////////////////////////////
  //////////////////////// Debut de la procedure module //////////////////
////////////////////////////////////////////////////////////////////////////
  reset_graine;
  iwriteln('Modules detection');
  {eps:=0.0000000001;}
  tour := 0;
  to_limit := 0;
  length_ggg := graphes[g].nb_sommets;
  nb_groups := 0;
  //association d'un noeud dans chaque groupe
  for i := 1 to graphes[g].nb_sommets do
    begin
      add_gp;
      add_spgp(i,i);
    end;
  //tous les noeuds dans 1 groupe
  {add_gp();
  for i:=1 to graphes[g].nb_sommets do
  begin
    add_spgp(i,1);
  end;}
  calcul_groupe(g);
  init_energies(g);
  iwriteln('E init = ' + s_ecri_val(energy));
  for i := 1 to nb_groups do gp_sav[i] := group[i];
  ngroup_sav := nb_groups;
  energy_sav := energy;
  for i := 1 to nb_groups do gp_best[i] := group[i];
  ngroup_best := nb_groups;
  energy_best := energy;
  energy_ant := energy;
  t := ti;
  count := 0;
  cycle1 := sqr(graphes[g].nb_sommets);
  cycle2 := graphes[g].nb_sommets;
  tour := 0;
  while ((t > tf) and (count < limit)) do with graphes[g] do
    begin
   /////////deplacements de noeuds individuels//////////
      for i := 1 to cycle1 do
      begin
      if nb_groups > 1 then
        begin
          noeud := trunc(rand(nb_sommets)) + 1; //selection de l'sp a deplacer
          grA := ggg_gpe[noeud];
          repeat
            grB := trunc(rand(nb_sommets)) + 1;//nb_sommets car potentiellement deplacement vers gpe vide
          until ( grB <> grA );
          if grB > nb_groups then
            begin
             add_gp;
             grB := nb_groups;
            end;
          e := group[grA].ener;
          e1 := group[grB].ener;
          deplace_sp(pos_gpe(noeud,grA),grA,grB);
          if group[grA].nb_som = 0 then
            begin
              if grB = nb_groups then grB := grA;
              delete_gp(grA);
              calcul_groupe(g);
              Egroup_modul(g,grB);
              maj_energy(e,e1,0.0,group[grB].ener);
            end
          else
            begin
              calcul_groupe(g);
              Egroup_modul(g,grA);
              Egroup_modul(g,grB);
              maj_energy(e,e1,group[grA].ener,group[grB].ener);
            end;
          metropolis;
      end;
    end;  ////////////////////fin du for cycle1  ////////////////////
   ///////// debut ensuite du regroupement et split (1 fois chacun  pour un tour de boucle)////////////

  for i := 1 to cycle2 do
  begin   /////////////////Regroupement///////////////::
    if nb_groups > 1 then
    begin
      grA := trunc(rand(nb_groups)) + 1;
      grB := grA;
      repeat
        grB := trunc(rand(nb_groups)) + 1;
      until ( grB <> grA );
      e := group[grA].ener;
      e1 := group[grB].ener;
      for j := 1 to group[grB].nb_som do
        add_spgp(group[grB].sommets[j],grA);
      group[grB].nb_som := 0;
      if grA = nb_groups then grA := grB; //(cf methode de delete_gp)
      delete_gp(grB);
      calcul_groupe(g);
      Egroup_modul(g,grA);
      maj_energy(e,e1,group[grA].ener,0);
      metropolis;
    end;
    /////////// fin du regroupement de groupes  //////////////

   ///////////////debut du split_groupes //////////////
   if nb_groups < nb_sommets then  //on split que si moins de gpe que le max
    begin
      grA := trunc(rand(nb_groups)) + 1;  // on split grA
      if group[grA].nb_som> 1 then //si on tombe sur un sommet avec un seul gpe, on n'en tire pas un autre ?
      begin
        e := group[grA].ener;
        connex := false; //booleen, = 1 s'il y a des sp de 2 comp connexes ds le gpe considere...
        if nb_connect > 1 then   //ce passage reste pertinent pour AIC et TG
          if group[grA].nb_som > 1 then
            for j := 1 to group[grA].nb_som do with group[grA] do
              if ggg[sommets[1]].connect<>ggg[sommets[j]].connect then
                connex := true;
        if connex then //on separe selon les composantes connexes
          begin
            add_gp;
            j := 2;
            while j< group[grA].nb_som do with group[grA] do
              if ggg[sommets[1]].connect <> ggg[sommets[j]].connect then
                deplace_sp(j, grA, nb_groups)
              else
                j := j + 1;
          end
        else
        begin  //pas de comp connexes, 2 groupes aleatoires et on corrige avec des permutations
        // 1) separation en 2 groupes (non vides)
          add_gp;
          grB:=nb_groups;
          deplace_sp(2,grA, grB); //car on a au min 2 sp dans le gp a splitter
          j:=2;
          while j< group[grA].nb_som do
          begin
            x:=trunc(rand(2))+1;
            if x=1 then
            begin
              deplace_sp(j, grA, grB);
            end
            else j:=j+1;
          end;
        end;
        calcul_groupe(g);
        Egroup_modul(g, grA);
        Egroup_modul(g, grB);
        maj_energy(e,0,group[grA].ener,group[grB].ener);

        //2) permutations d'especes entre grA et grB (sous_simul)
        if group[grA].nb_som + group[grB].nb_som >2 then
          sous_simul(g, grA, grB);

        metropolis;
      end;
    end; //fin du split
   end;//fin du split/merge  (cycle2)


//debut de la maj de la temperature et du compteur
       {writeln(f,'tour:  '+inttostr(tour)+'    count: ' + inttostr(count)
   + '  nb groups: ' + inttostr(nb_groups) + ' energy: ' + floattostr(energy)
   + ' energy_ant: ' + floattostr(energy_ant)
   + '  temp: ' + floattostr(t)+ '  time:  ' + DateTimeToStr(Now));}

    if energy_ant = 0.0 then energy_ant := eps;
    if to_limit < 2 then
    begin
      if (abs(energy-energy_ant)/abs(energy_ant) < eps) or (abs(energy_ant) < eps) then
        begin
          count := count + 1;
          if ((count = limit) and (energy+eps < energy_best)) then
          begin
            to_limit:=to_limit + 1;
            for i := 1 to ngroup_best do group[i] := gp_best[i];
            nb_groups := ngroup_best;
            energy := energy_best;
            count := 0;
            t := t*sqr(ts);
            reactualise_gpes;
          end;
        end
        else
          count := 0;
    end
    else
      count := limit;

    if energy > energy_best then
      begin
        for i := 1 to nb_groups do gp_best[i] := group[i];
        ngroup_best := nb_groups;
        energy_best := energy;
      end;

    energy_ant := energy;

  t := t*ts;
  tour := tour+1;

   iwriteln(IntToStr(tour) + ' <' + IntToStr(count) + '> '
   + ' nb groups = ' + IntToStr(nb_groups) + ' E = ' + s_ecri_val(energy));

  end;

  energy := energy_best;
  for i := 1 to ngroup_best do group[i] := gp_best[i];
  nb_groups := ngroup_best;
  reactualise_gpes;

  info_groupe(g);

  iwriteln('E final = ' + s_ecri_val(energy));
  iwriteln('nb of modules = ' + IntToStr(nb_groups));

  for i:=1 to nb_groups do with group[i] do
  begin
    iwriteln('Group ' + IntToStr(i) + '    size = ' + IntToStr(nb_som));
    iwriteln('    in_degree  = ' + IntToStr(in_degree) +
             ' out_degree = ' + IntToStr(out_degree) +
             '    inlinks  = ' + IntToStr(inlinks) +
             ' outlinks = ' + IntToStr(outlinks));
  end;

end;

end.

