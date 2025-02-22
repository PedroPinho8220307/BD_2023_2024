USE [Greenhouses_BD]
GO
/****** Object:  Trigger [dbo].[trigger_UpdateLastMaintenanceDate]    Script Date: 30/05/2024 11:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Grupo 101
-- Create date: 27/05/2024
-- Description: Atualiza a última data de manutenção na tabela Structure
-- =============================================
ALTER   TRIGGER [dbo].[trigger_UpdateLastMaintenanceDate] 
   ON  [dbo].[Maintenance]
   AFTER INSERT, UPDATE
AS 
BEGIN
    -- SET NOCOUNT ON adicionado para evitar conjuntos de resultados extras
    -- interferindo com instruções SELECT.
    SET NOCOUNT ON;

	DECLARE @DiferentStructuresCount INT;
    DECLARE @MaxMaintenanceDate DATE;

	-- Obtem o número de estruturas diferentes onde foram inseridas manutenções
	SELECT @DiferentStructuresCount = COUNT(DISTINCT Inserted.StructureNo)
	FROM inserted

	IF @DiferentStructuresCount > 1 BEGIN
		ROLLBACK;
		RAISERROR('Não podem ser inseridas múltiplas manutenções de estruturas diferentes!', 16, 1);
	END
	ELSE BEGIN
		-- Obtém a maior data de manutenção inserida ou atualizada
		SELECT @MaxMaintenanceDate = MAX(Date)
		FROM inserted;

		-- Atualiza a última data de manutenção na tabela Structure se a nova data for maior
		UPDATE s
		SET s.LastMaintenanceDate = @MaxMaintenanceDate
		FROM dbo.Structure s
		WHERE s.StructureNo IN (SELECT StructureNo FROM inserted)
		AND (@MaxMaintenanceDate > s.LastMaintenanceDate OR s.LastMaintenanceDate IS NULL);
	END

END;
