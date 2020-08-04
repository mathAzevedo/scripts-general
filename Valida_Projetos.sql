-- =============================================
-- Autor: Matheus do Carmo Azevedo
-- Criado em: 22/04/2020
-- Descricao: https://data4all.data.blog/2020/04/22/validate-de-projetos-script-para-validacao-de-todos-os-projetos-do-ssis/
-- =============================================

/* Declara as variaveis */

DECLARE @validation_id BIGINT
DECLARE @projeto VARCHAR(200)
DECLARE @pasta VARCHAR(100)

/* Declara cursor que ira ler cada pasta e projeto */

DECLARE cursor_validate CURSOR FOR
SELECT DISTINCT f.name, p.name
FROM SSISDB.catalog.projects as p
INNER JOIN SSISDB.catalog.folders as f
ON p.folder_id = f.folder_id

/* Abre o cursor */
OPEN cursor_validate
FETCH NEXT FROM cursor_validate INTO @pasta, @projeto

WHILE @@FETCH_STATUS = 0
-- Inicio da validacao chamando a proc do SSISDB validate_project
BEGIN
EXEC [SSISDB].[catalog].[validate_project] @project_name=@projeto, @validation_id=@validation_id OUTPUT, @folder_name=@pasta, @validate_type=F, @use32bitruntime=False, @environment_scope=D, @reference_id=Null
SELECT @validation_id

-- Espera 5 segundos para validar o proximo projeto para evitar o alto consumo de recursos da maquina por processos concorrentes
WAITFOR DELAY '00:00:05'

FETCH NEXT FROM cursor_validate INTO @pasta, @projeto
END

CLOSE cursor_validate
DEALLOCATE cursor_validate