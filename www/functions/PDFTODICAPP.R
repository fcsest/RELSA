#CHAMANDO OS PACKAGES
library(textreadr)
library(stringr)
library(magrittr)
library(plyr)

#DECLARANDO A FUNÇÃO
pdftodicn <- function(ATIV,LETR)
  
{
  
  BIN <- '\\([A-Z](?'
  PAR <- '\\('
  CHAR <- 'CAMPO DE TEXTO'
  OU <- '|'
  CHOICES <- "\\[1]"
  
  LETR <- toupper(LETR)
  
  MAPA <- read_pdf(ATIV)
  
  
  TEXTO <- MAPA$text[str_detect(MAPA$text, paste(PAR, OU, CHAR, OU, CHOICES, sep=""))]
  
  
  LINESCHOICES <- TEXTO[which(str_detect(TEXTO, "\\[1]")) - 1]
  
  
  QCHOICES <- LINESCHOICES[!str_detect(LINESCHOICES, "\\[1]")]
  
  
  IDCHOICES <- unlist(str_extract_all(QCHOICES, "(?<=\\().+?(?=\\))"))
  
  
  CHOICES <- IDCHOICES[substr(IDCHOICES, 4, 4)==LETR]
  
  
  PARENTESIS <- unlist(str_extract_all(TEXTO, "(?<=\\().+?(?=\\))|CAMPO DE TEXTO"))
  
  
  IDSMAPA <- PARENTESIS[substr(PARENTESIS, 4, 4)==LETR | str_detect(PARENTESIS, "CAMPO DE TEXTO")]
  
  
  IDS <- IDSMAPA[!str_detect(IDSMAPA, paste("AFERIDOR", OU, "DATAAPINI", OU, LETR, "Z", sep=""))]
  
  
  CHARS <- IDS[which(str_detect(IDS, "CAMPO DE TEXTO")) - 1]
  
  
  VARS <- IDS[!str_detect(IDS, "CAMPO DE TEXTO")]
  
  
  NAME <- VARS[!VARS %in% CHOICES]
  
  if(length(CHARS)==0)
  {
    TYPE <- rep(1,length(VARS))
  } 
  if(length(CHARS)>0)
  {
    FORMATS <- str_detect(NAME, str_c(CHARS, collapse="|"))
  }
  
  
  if(length(CHARS)==0)
  {
    BANCO <- data.frame(NAME, round(TYPE))
  } 
  if(length(CHARS)>0)
  {
    BANCO <- data.frame(NAME, FORMATS)
  }
  
  
  if(length(CHARS)>0)
  {
    BANCO$TYPE <- as.integer(BANCO$FORMAT == "TRUE")
    BANCO$TYPE[BANCO$FORMATS=="FALSE"] <- round(1)
    BANCO$TYPE[BANCO$FORMATS=="TRUE"] <- round(2)
    BANCO$FORMATS <- NULL
  }
  return(BANCO)
}
