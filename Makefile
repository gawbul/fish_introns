freeze:
	poetry lock

install:
	poetry install --sync

format:
	poetry run ruff format .

nbstripout:
	poetry run nbstripout notebooks/*.ipynb

install-poetry:
	curl -sSL https://install.python-poetry.org | python3 - --version=$(cat .poetry-version)

uninstall-poetry:
	curl -sSL https://install.python-poetry.org | python3 - --uninstall

nf-get-introns:
	nextflow run get_introns.nf

nf-get-genes:
	nextflow run get_genes.nf
