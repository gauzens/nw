unit kaic;

interface

procedure simul_aic(g : integer; tf,ti,ts,eps : extended);

implementation

uses SysUtils,kglobvar,kgroup,kmath,kutil,ksyntax;

var energy,llh : extended;
    gp_sav,gp_saved,gp_best : groups;

procedure info_groupe(g : integer);
var x,y,k,j,c : integer;
begin
with graphes[g] do
  begin
    init_mat_groupe;
    for k := 1 to nb_groups do with group[k] do
      begin
        inlinks  := 0;
        outlinks := 0;
        out_degree := 0;
        in_degree  := 0;
      end;
    for k := 1 to nb_groups do with group[k] do
      for j := 1 to nb_som do //sp j du groupe k
        begin
          x := sommets[j]; //x: pos ds ggg de la j sp du gpe k
          y := ggg[x].succ;  // y est le succ de l'espèce x
          while ( y <> 0 ) do with lis[y] do
            begin
              c := ggg_gpe[car];
              mgr_[k,c] := mgr_[k,c] + 1; //non necessaire ici
              out_degree := out_degree + 1; //peut se faire une fois tout à la fin
              group[c].in_degree := group[c].in_degree + 1;
              if ( ggg_gpe[x] = c ) then
                inlinks := inlinks + 1
              else
                begin
                  outlinks := outlinks + 1;
                  group[c].outlinks := group[c].outlinks+1;
                end;
              y := cdr;
            end;
        end;
  end;
end;

procedure calcul_groupe(g : integer);
var x,y,k,j : integer;
begin
  with graphes[g] do
    begin
      init_mat_groupe;
      for k := 1 to nb_groups do with group[k] do
        for j := 1 to nb_som do //sp j du groupe k
          begin
            x := sommets[j]; //x: pos ds ggg de la j sp du gpe k
            y := ggg[x].succ;  // y est le succ de l'espece x
            while ( y <> 0 ) do with lis[y] do
              begin
                mgr_[k,ggg_gpe[car]] := mgr_[k,ggg_gpe[car]] + 1;
                y := cdr;
              end;
          end;
    end;
end;

procedure Egroup_aic(g, gp : integer);
var m : integer;
    aic,proba,log_proba,log_moin_proba : extended;
begin
with group[gp] do
  begin
    aic := 0.0;
    for m := 1 to nb_groups do
      if nb_som*group[m].nb_som > 0 then // a priori superflu
        begin
          proba := mgr_[gp,m]/(nb_som*group[m].nb_som);
          if (proba = 1.0) or (proba = 0.0) then
            begin
              log_proba := 0.0;
              log_moin_proba := 0.0;
            end
          else
            begin
              log_proba := ln(proba);
              log_moin_proba := ln(1.0-proba);
            end;
          aic := aic + mgr_[gp,m]*log_proba + (nb_som*group[m].nb_som - mgr_[gp,m])*log_moin_proba;
        end;
    ener := 2.0*aic;
  end;
end;

procedure calcul_energies(g : integer);
var i : integer;
begin
  energy := 0.0;
  llh := 0.0;
  for i := 1 to nb_groups do
    begin
      egroup_aic(g,i);
      llh := llh + group[i].ener;
    end;
  energy := 1000.0/(2.0*(sqr(nb_groups) + graphes[g].nb_sommets) - llh);
end;

procedure simul_aic(g : integer; tf,ti,ts,eps : extended);
var i,j,k,x,y,count,cycle1,cycle2,grA,grB,noeud,ngroup_sav,ngroup_best,tour,g1,to_limit: integer;
    energy_sav,energy_best,energy_ant,T : extended;
    llh_sav,llh_best : extended; // 2*vraisemblance pour formule AIC
    connex : boolean; //presence de plusieurs comp connexes
const limit = 20;

procedure metropolis; //accepte ou non les changements faits
var i : integer;
begin
  if ( (energy > energy_sav) or (exp((energy-energy_sav)/t)>rand(1.0)) ) then
    begin  // on sauvegarde les changements
      energy_sav := energy;
      for i := 1 to nb_groups do gp_sav[i] := group[i];
      ngroup_sav := nb_groups;
      llh_sav := llh;
    end
  else
    begin        //sinon, on repart de energy sav
      for i := 1 to ngroup_sav do group[i] := gp_sav[i];
      nb_groups := ngroup_sav;
      energy := energy_sav;
      llh := llh_sav;
      reactualise_gpes;
    end;
end;

procedure sous_simul(g : integer; grA : integer; grB : integer);
var x,y,ngroup_saved,i : integer;
    tsplit,energy_saved,llh_saved : extended;
begin
  with graphes[g] do
    begin
      tsplit := ti;
      energy_saved := energy;
      for i := 1 to nb_groups do gp_saved[i] := group[i];
      ngroup_saved := nb_groups;
      llh_saved := llh;
      while ( tsplit >= t ) do
        begin
          for x := 1 to group[grA].nb_som + group[grB].nb_som do
            if ( group[grA].nb_som > group[grB].nb_som ) then
              begin
                y := trunc(rand(group[grA].nb_som)) + 1;
                deplace_sp(y,grA,grB);
              end
            else
              begin
                y := trunc(rand(group[grB].nb_som)) + 1;
                deplace_sp(y,grB,grA);
              end;
          calcul_groupe(g);
          calcul_energies(g);
          //sous metropolis:
          if ((energy>energy_saved) or (rand(1)< exp((energy-energy_saved)/tsplit))) then
            begin
              for i := 1 to nb_groups do gp_saved[i] := group[i];
              ngroup_saved := nb_groups;
              energy_saved := energy;
              llh_saved := llh;
            end
          else
            begin
              for i := 1 to ngroup_saved do group[i] := gp_saved[i];
              nb_groups := ngroup_saved;
              energy := energy_saved;
              llh := llh_saved;
              reactualise_gpes;
            end;
          tsplit:=tsplit*ts;
        end;
    end;
end;

begin
////////////////////////////////////////////////////////////////////////////
  //////////////////////// Debut de la procedure  //////////////////
////////////////////////////////////////////////////////////////////////////
  reset_graine;
  iwriteln('AIC groups detection');
  to_limit := 0; //pour eviter de boucler dans les "count" a la fin
  length_ggg := graphes[g].nb_sommets;
  nb_groups := 0;
  //association d'un noeud dans chaque groupe
  for i := 1 to graphes[g].nb_sommets do
    begin
      add_gp;
      add_spgp(i,i);
    end;
  calcul_groupe(g);
  calcul_energies(g);
  iwriteln('E init = ' + FloatToStr(energy));
  for i := 1 to nb_groups do gp_sav [i] := group[i];
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
            noeud := trunc(rand(nb_sommets)) + 1; //selection de l'sp à deplacer
            grA := ggg_gpe[noeud];
            repeat
              grB := trunc(rand(nb_sommets)) + 1;//nb_sommets car potentiellement deplacement vers gpe vide
            until ( grB <> grA );
            if grB > nb_groups then
              begin
               add_gp;
               grB := nb_groups;
              end;
            deplace_sp(pos_gpe(noeud,grA),grA,grB);
            if ( group[grA].nb_som = 0 ) then
              begin
                if grB = nb_groups then grB := grA;
                delete_gp(grA);
                calcul_groupe(g);
                calcul_energies(g);
              end
            else
              begin
                calcul_groupe(g);
                calcul_energies(g);
              end;
            metropolis;
        end;
    end;  ////////////////////fin du for cycle1  ////////////////////
   ///////// début ensuite du regroupement et split (1 fois chacun  pour un tour de boucle)////////////

  for i:=1 to cycle2 do
  begin   /////////////////Regroupement///////////////::

    if nb_groups > 1 then
    begin
      grA := trunc(rand(nb_groups)) + 1;
      repeat
        grB := trunc(rand(nb_groups)) + 1;
      until grB <> grA;

      for j := 1 to group[grB].nb_som do
        add_spgp(group[grB].sommets[j],grA);
      group[grB].nb_som := 0;
      if grA = nb_groups then grA := grB; //(cf methode de delete_gp)
      delete_gp(grB);

      calcul_groupe(g);

      calcul_energies(g);

      metropolis;
    end;
    /////////// fin du regroupement de groupes  //////////////

   ///////////////début du split_groupes //////////////

   if nb_groups<nb_sommets then  //on split que si moins de gpe que le max
    begin
      grA := trunc(rand(nb_groups)) + 1;  // on split grA
      if group[grA].nb_som> 1 then //si on tombe sur un sommet avec un seul gpe, on n'en tire pas un autre ?
      begin
        connex:=false; //booleen, = 1 s'il y a des sp de 2 comp connexes ds le gpe considéré...
        if nb_connect > 1 then   //ce passage reste pertinant pour AIC et TG
          for j := 1 to group[grA].nb_som do with group[grA] do
              if ggg[sommets[1]].connect <> ggg[sommets[j]].connect then
                connex:=true;

        if connex=true then //on separe selon les composantes connexes
        begin
          add_gp();
          j:=2;
          while j< group[grA].nb_som do with group[grA] do
          begin
            if ggg[sommets[1]].connect <> ggg[sommets[j]].connect then
            begin
              deplace_sp(j, grA, nb_groups);
            end
            else j:=j+1;
          end;
        end
        else
        begin  //pas de comp connexes, 2 groupes aleatoires et on corrige avec des permutations
        // 1) séparation en 2 groupes (non vides)
          add_gp;
          grB := nb_groups;
          deplace_sp(2,grA,grB); //car on a au min 2 sp dans le gp a splitter
          j := 2;
          while j < group[grA].nb_som do
            if ( ber(0.5) = 1.0 ) then
              deplace_sp(j,grA,grB)
            else
              j := j+1;
        end;
        calcul_groupe(g);

        calcul_energies(g);

        //2) permutations d'espèces entre grA et grB (sous_simul)
        if ( group[grA].nb_som + group[grB].nb_som > 2 ) then
          sous_simul(g,grA,grB);

        metropolis;
      end;
    end; //fin du split
   end;//fin du split/merge  (cycle2)


//début de la maj de la température et du compteur
       {writeln(f,'tour:  '+inttostr(tour)+'    count: ' + inttostr(count)
   + '  nb groups: ' + inttostr(nb_groups) + ' energy: ' + floattostr(energy)
   + ' energy_ant: ' + floattostr(energy_ant)
   + '  temp: ' + floattostr(t)+ '  time:  ' + DateTimeToStr(Now));}

    if energy_ant = 0.0 then energy_ant := eps;
    if to_limit < 50 then
    begin
      if (abs(energy-energy_ant)/abs(energy_ant) < eps) or  (abs(energy_ant) < eps) then
        begin
          count := count + 1;
          if ((count = limit) and (energy+eps < energy_best)) then
          begin
            to_limit := to_limit + 1;
            for i := 1 to ngroup_best do group[i] := gp_best[i];
            nb_groups := ngroup_best;
            energy := energy_best;
            count := 0;
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
  tour := tour + 1;

   iwriteln(IntToStr(tour) + ' <' + IntToStr(count) + '> '
   + ' nb groups = ' + IntToStr(nb_groups) + ' E = ' + s_ecri_val(energy));

  end; { while principal }

  for i := 1 to ngroup_best do group[i] := gp_best[i];
  nb_groups := ngroup_best;
  energy := energy_best;
  reactualise_gpes;

  info_groupe(g);

  iwriteln('E final = ' + s_ecri_val(energy) + ' AIC = ' + s_ecri_val(1000.0/energy));
  iwriteln('nb of AIC groups = ' + IntToStr(nb_groups));

  for i := 1 to nb_groups do with group[i] do
  begin
    iwriteln('Group ' + IntToStr(i) + '    size = ' + IntToStr(nb_som));
    iwriteln('    in_degree  = ' + IntToStr(in_degree) +
             ' out_degree = ' + IntToStr(out_degree) +
             '    inlinks  = ' + IntToStr(inlinks) +
             ' outlinks = ' + IntToStr(outlinks));
  end;

end;

end.
