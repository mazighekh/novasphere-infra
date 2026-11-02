# Conventions d'equipe NovaSphere

- Une branche par changement, jamais de commit direct sur main.
- Toute pull request est relue par l'autre membre du binome avant merge.
- Un tag par seance : v5.<seance>.0 (v5.1.0 pour la S1).
- Le plan Terraform se lit en entier avant tout apply.
- .gitignore non negociable : *.tfstate, *.tfvars, *.pem, .env, inventaires generes.
- State partage dans S3 (novasphere-tfstate-mkh), verrouillage natif use_lockfile.
- dynamodb_table est deprecie par HashiCorp : on ne l'utilise pas.
- Jamais de force-unlock sans avoir verifie que personne n'a d'operation en cours.
- destroy ou ./scripts/stop-evening.sh avant de quitter la salle.
