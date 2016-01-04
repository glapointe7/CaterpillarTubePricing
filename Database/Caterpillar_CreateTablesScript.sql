SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `Caterpillar` DEFAULT CHARACTER SET utf8 ;
USE `Caterpillar` ;

-- -----------------------------------------------------
-- Table `Caterpillar`.`ComponentType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`ComponentType` (
  `pkComponentType` SMALLINT NOT NULL,
  `name` VARCHAR(75) NOT NULL,
  PRIMARY KEY (`pkComponentType`),
  UNIQUE INDEX `pkComponentType_UNIQUE` (`pkComponentType` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`ConnectionType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`ConnectionType` (
  `pkConnectionType` SMALLINT NOT NULL,
  `name` VARCHAR(75) NOT NULL,
  UNIQUE INDEX `pkConnectionType_UNIQUE` (`pkConnectionType` ASC),
  PRIMARY KEY (`pkConnectionType`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeEndForm`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeEndForm` (
  `pkTubeEndForm` SMALLINT NOT NULL,
  `forming` BIT NOT NULL,
  UNIQUE INDEX `pkTubeEndForm_UNIQUE` (`pkTubeEndForm` ASC),
  PRIMARY KEY (`pkTubeEndForm`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component` (
  `pkComponent` SMALLINT NOT NULL,
  `fkComponentType` SMALLINT NOT NULL,
  `weight` DECIMAL(8,3) NOT NULL,
  UNIQUE INDEX `pkComponent_UNIQUE` (`pkComponent` ASC),
  PRIMARY KEY (`pkComponent`),
  INDEX `fkComponentType_idx` (`fkComponentType` ASC),
  CONSTRAINT `fkComponentType`
    FOREIGN KEY (`fkComponentType`)
    REFERENCES `Caterpillar`.`ComponentType` (`pkComponentType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`EndFormType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`EndFormType` (
  `pkEndFormType` SMALLINT NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`pkEndFormType`),
  UNIQUE INDEX `pkEndFormType_UNIQUE` (`pkEndFormType` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeAssembly`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssembly` (
  `pkTubeAssembly` SMALLINT NOT NULL,
  `materialID` SMALLINT NOT NULL,
  `diameter` DECIMAL(8,2) NOT NULL,
  `wallThickness` DECIMAL(8,2) NOT NULL,
  `length` MEDIUMINT NOT NULL,
  `numberOfBends` TINYINT NOT NULL,
  `bendRadius` DECIMAL(8,2) NOT NULL,
  `endA1X` BIT NOT NULL,
  `endA2X` BIT NOT NULL,
  `endX1X` BIT NOT NULL,
  `endX2X` BIT NOT NULL,
  `fkTubeEndFormA` SMALLINT NULL,
  `fkTubeEndFormX` SMALLINT NULL,
  `numberOfBoss` TINYINT NOT NULL,
  `numberOfBracket` TINYINT NOT NULL,
  `other` TINYINT NOT NULL,
  `specs` VARCHAR(150) NULL,
  PRIMARY KEY (`pkTubeAssembly`),
  UNIQUE INDEX `pkTubeAssembly_UNIQUE` (`pkTubeAssembly` ASC),
  INDEX `fkTubeEndFormA_idx` (`fkTubeEndFormA` ASC),
  INDEX `fkTubeEndFormX_idx` (`fkTubeEndFormX` ASC),
  CONSTRAINT `fkTubeEndFormA`
    FOREIGN KEY (`fkTubeEndFormA`)
    REFERENCES `Caterpillar`.`TubeEndForm` (`pkTubeEndForm`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkTubeEndFormX`
    FOREIGN KEY (`fkTubeEndFormX`)
    REFERENCES `Caterpillar`.`TubeEndForm` (`pkTubeEndForm`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeAssembly_Component`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssembly_Component` (
  `fkTubeAssembly` SMALLINT NOT NULL,
  `fkComponent` SMALLINT NOT NULL,
  `quantity` TINYINT NULL,
  INDEX `fkTubeAssembly_idx` (`fkTubeAssembly` ASC),
  INDEX `fkComponent_idx` (`fkComponent` ASC),
  CONSTRAINT `fkTubeAssembly`
    FOREIGN KEY (`fkTubeAssembly`)
    REFERENCES `Caterpillar`.`TubeAssembly` (`pkTubeAssembly`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkComponent`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`TubeAssemblyPricing`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssemblyPricing` (
  `pkTubeAssemblyPricing` MEDIUMINT NOT NULL AUTO_INCREMENT,
  `fkTubeAssembly` SMALLINT NOT NULL,
  `supplierID` SMALLINT NOT NULL,
  `quoteDate` DATE NOT NULL,
  `anualUsage` INT NOT NULL,
  `minOrderQuantity` SMALLINT NOT NULL,
  `bracketPricing` BIT NOT NULL,
  `quantity` SMALLINT NOT NULL,
  `cost` DECIMAL(15,10) NOT NULL,
  PRIMARY KEY (`pkTubeAssemblyPricing`),
  UNIQUE INDEX `pkTubeAssemblyPricing_UNIQUE` (`pkTubeAssemblyPricing` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Caterpillar`.`Component_Connection`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`Component_Connection` (
  `fkComponent` SMALLINT NOT NULL,
  `fkEndFormType` SMALLINT NULL,
  `fkConnectionType` SMALLINT NULL,
  `length` DECIMAL(8,2) NULL,
  `threadSize` DECIMAL(8,2) NULL,
  `threadPitch` DECIMAL(8,2) NULL,
  `nominalSize` DECIMAL(8,2) NULL,
  INDEX `fkEndFormTypeConnection_idx` (`fkEndFormType` ASC),
  INDEX `fkConnectionConnection_idx` (`fkConnectionType` ASC),
  INDEX `fkComponentConnection_idx` (`fkComponent` ASC),
  CONSTRAINT `fkComponentConnection`
    FOREIGN KEY (`fkComponent`)
    REFERENCES `Caterpillar`.`Component` (`pkComponent`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkEndFormTypeConnection`
    FOREIGN KEY (`fkEndFormType`)
    REFERENCES `Caterpillar`.`EndFormType` (`pkEndFormType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fkConnectionConnection`
    FOREIGN KEY (`fkConnectionType`)
    REFERENCES `Caterpillar`.`ConnectionType` (`pkConnectionType`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `Caterpillar` ;

-- -----------------------------------------------------
-- Placeholder table for view `Caterpillar`.`TubeAssemblyWeightView`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssemblyWeightView` (`fkTubeAssembly` INT, `totalWeight` INT, `numberOfComponents` INT);

-- -----------------------------------------------------
-- Placeholder table for view `Caterpillar`.`TubeAssemblyQuantityView`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Caterpillar`.`TubeAssemblyQuantityView` (`fkTubeAssembly` INT, `minQty` INT, `maxQty` INT);

-- -----------------------------------------------------
-- View `Caterpillar`.`TubeAssemblyWeightView`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Caterpillar`.`TubeAssemblyWeightView`;
USE `Caterpillar`;
CREATE  OR REPLACE VIEW `TubeAssemblyWeightView` AS
	Select TAC.fkTubeAssembly, SUM(C.weight * TAC.quantity) AS totalWeight,
		   COUNT(TAC.fkComponent) AS numberOfComponents
	From Component AS C
		INNER JOIN TubeAssembly_Component AS TAC ON C.pkComponent = TAC.fkComponent
	GROUP BY TAC.fkTubeAssembly ASC;

-- -----------------------------------------------------
-- View `Caterpillar`.`TubeAssemblyQuantityView`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Caterpillar`.`TubeAssemblyQuantityView`;
USE `Caterpillar`;
CREATE  OR REPLACE VIEW `TubeAssemblyQuantityView` AS
	SELECT TAP.fkTubeAssembly, MIN(TAP.quantity) AS minQty, MAX(TAP.quantity) AS maxQty
	FROM TubeAssemblyPricing AS TAP
	GROUP BY TAP.fkTubeAssembly ASC;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
