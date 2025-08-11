uses windows, wincrt, wingraph, winmouse;


// TODO: win screen, gameover screen
// TODO: TIMER im Info_screen
// TODO: Minecounter im Info_screen

const
  ROWS = 10;
  COLUMNS = 10;
  MINES = 25;

  FIELD_SIZE = 25;
  CONNECTION = 50;
  INFO_SCREEN = 75;


TYPE T_fieldData = PACKED RECORD
  number  : BYTE;
  isvisible : BOOLEAN;
  isFlagged : BOOLEAN;
END;
var 
    fieldData : array[0..COLUMNS-1, 0..ROWS-1] of T_fieldData;
    generatedMines, gameover, won : BOOLEAN;

function RGBColor( r, g, b : BYTE) : LONGINT;
begin
  RGBColor := r + (g SHL 8 ) + (b SHL 16);
end;

procedure Austausch( var a, b : INTEGER );
var c : INTEGER;
begin
  c := a;
  a := b;
  b := c;
end;

// Field number X To Cords
function xTC(x : BYTE) : WORD;
begin
  xtC := 25 + FIELD_SIZE * x;
end;

function yTC(y : BYTE) : WORD;
begin
  ytC := INFO_SCREEN + FIELD_SIZE * y;
end;

procedure background;
begin
  SetColor(RGBColor(75, 75, 75));
  SetFillStyle(SolidFill, RGBColor(100, 100, 100));
  FillRect( 25 - 2, INFO_SCREEN - 2, COLUMNS*FIELD_SIZE + 2 + 25, INFO_SCREEN + ROWS*FIELD_SIZE + 2);
  

end;

procedure hiddenField(x, y : WORD);
var i : BYTE;
begin
  x := xTC(x); y := yTC(y);

  SetColor(RGBColor(145, 145, 145));
  SetFillStyle(SolidFill, RGBColor(145, 145, 145));
  FillRect( x, y, x + FIELD_SIZE, y + FIELD_SIZE);
  
  // Helle bereich (links oben)
  SetColor(RGBColor(200, 200, 200));
  FOR i := 0 TO ROUND(FIELD_SIZE / 10) DO begin
    MoveTo(x, y + i);
    LineTo(x - i + FIELD_SIZE, y + i);
    MoveTo(x + i, y + ROUND(FIELD_SIZE / 10));
    LineTo(x + i, y - i + FIELD_SIZE);
  end;

  // dunkle bereich (rechts unten)
  SetColor(RGBColor(100, 100 , 100));
  FOR i := 0 TO ROUND(FIELD_SIZE / 10) DO begin
    MoveTo(x + i, y - i + FIELD_SIZE);
    LineTo(x + FIELD_SIZE, y - i + FIELD_SIZE);
    MoveTo(x - i + FIELD_SIZE, y + i);
    LineTo(x - i + FIELD_SIZE, y + FIELD_SIZE - ROUND(FIELD_SIZE/10));
  end;

end;

function degToRad(deg : REAL) : REAL;
begin
  degToRad := deg * PI/180;
end;

procedure RotatedRect(ax, ay, ex, ey: Integer; angle: Double; color: Word);
var
  cx, cy: REAL;
  halfWidth, halfHeight : REAL; 
  radAngle : REAL;
  corners : array[0..3, 0..1] of REAL;
  points : array[1..4] of PointType;
  i : BYTE;
  tempX, tempY : REAL;
begin
  cx := (ax + ex) / 2.0;
  cy := (ay + ey) / 2.0;

  halfWidth := abs(ex - ax) / 2.0;
  halfHeight := abs(ey - ay) / 2.0;

  radAngle := DegToRad(angle);

  corners[0][0] := -halfWidth;  corners[0][1] := -halfHeight;
  corners[1][0] := halfWidth;   corners[1][1] := -halfHeight;
  corners[2][0] := halfWidth;   corners[2][1] := halfHeight;
  corners[3][0] := -halfWidth;  corners[3][1] := halfHeight;

  FOR i := 0 to 3 DO begin
    tempX := corners[i][0] * Cos(radAngle) - corners[i][1] * Sin(radAngle);
    tempY := corners[i][0] * Sin(radAngle) + corners[i][1] * Cos(radAngle);

    corners[i][0] := tempX + cx;
    corners[i][1] := tempY + cy;

    points[i + 1].x := Round(corners[i][0]);
    points[i + 1].y := Round(corners[i][1]);
  end;

  SetFillStyle(SolidFill, color);
  FillPoly(4, points);

  SetColor(color);
  Line(points[1].x, points[1].y, points[2].x, points[2].y);
  Line(points[2].x, points[2].y, points[3].x, points[3].y);
  Line(points[3].x, points[3].y, points[4].x, points[4].y);
  Line(points[4].x, points[4].y, points[1].x, points[1].y);
end;

procedure fillcircle(cx, cy, r : INTEGER); 
var x, y, dx : INTEGER;
begin
  for x := r downto 0 do begin
    y := round(sqrt(sqr(r) - sqr(x)));
    dx := cx - x;
    line(dx - 1, cy - y, dx - 1, cy + y);
    dx := cx + x;
    line(dx, cy - y, dx, cy + y);
  end;
end;

procedure numberField(x, y : WORD; number : BYTE);
var outputString : String;
    i, mX, mY    : BYTE;

begin
  x := xTC(x); y := yTC(y);

  SetColor(RGBColor(145, 145, 145));
  SetFillStyle(SolidFill, RGBColor(145, 145, 145));
  FillRect( x, y, x + FIELD_SIZE, y + FIELD_SIZE);

  // Field Outline
  SetColor(RGBColor(100, 100, 100));
  FOR i := 0 TO ROUND(FIELD_SIZE/40) DO Rectangle( x - i, y + i, x + FIELD_SIZE - i, y + FIELD_SIZE - i);

  MoveTo(x + FIELD_SIZE SHR 1, y);
  IF ( (number >= 1) and (number <= 8)) then begin
    IF (number = 1) THEN SetColor(RGBColor(0, 0, 255));
    IF (number = 2) THEN SetColor(RGBColor(0, 255, 0));
    IF (number = 3) THEN SetColor(RGBColor(255, 0, 0));
    IF (number = 4) THEN SetColor(RGBColor(0, 0, 128));
    IF (number = 5) THEN SetColor(RGBColor(128, 0, 0));
    IF (number = 6) THEN SetColor(RGBColor(0, 128, 0));
    IF (number = 7) THEN SetColor(RGBColor(0, 255, 255));
    IF (number = 8) THEN SetColor(RGBColor(128, 0, 128));
  SetTextJustify(CenterText, TopText);
  SetTextStyle(CourierNewFont, HorizDir, ROUND(FIELD_SIZE * 1.2));
  str(number, outputString);
  OutText(outputString);
  end ELSE begin
    IF number = 9 then begin
      // bombe
      SetColor(RGBColor(20, 20, 20));
      SetFillStyle(SolidFill, RGBColor(20, 20, 20));
      fillcircle(x + FIELD_SIZE SHR 1, y + FIELD_SIZE SHR 1, FIELD_SIZE SHR 2);
      FillRect(ROUND(x + FIELD_SIZE SHR 4), ROUND(y - FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), ROUND(x - FIELD_SIZE SHR 4) + FIELD_SIZE, ROUND(y + FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1));
      FillRect(ROUND(x - FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1),ROUND(y + FIELD_SIZE SHR 4), ROUND(x + FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), ROUND(y - FIELD_SIZE SHR 4) + FIELD_SIZE);
      RotatedRect(ROUND(x + FIELD_SIZE SHR 4), ROUND(y - FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), ROUND(x - FIELD_SIZE SHR 4) + FIELD_SIZE, ROUND(y + FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), 45, RGBColor(20, 20, 20)); 
      RotatedRect(ROUND(x - FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), ROUND(y + FIELD_SIZE SHR 4), ROUND(x + FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), ROUND(y - FIELD_SIZE SHR 4) + FIELD_SIZE, 45, RGBColor(20, 20, 20)); 
    end;
  end;
end;

procedure FilledTriangle(x1, y1, x2, y2: INTEGER; color: WORD);
var
  x3, y3 : REAL;
  points: array[1..3] of PointType;
  midX, midY : REAL;
  length, height : REAL;
begin
  midX := (x1 + x2) / 2.0;
  midY := (y1 + y2) / 2.0;

  length := sqrt(sqr(x2 - x1) + sqr(y2 - y1));

  height := (length * sqrt(3.0)) / 2.0;

  x3 := midX - (height * (y2 - y1) / length);
  y3 := midY + (height * (x2 - x1) / length);

  points[1].x := x1;
  points[1].y := y1;
  points[2].x := x2;
  points[2].y := y2;
  points[3].x := Round(x3);
  points[3].y := Round(y3);

  SetFillStyle(SolidFill, color);
  FillPoly(3, points);

  SetColor(color);
  Line(points[1].x, points[1].y, points[2].x, points[2].y);
  Line(points[2].x, points[2].y, points[3].x, points[3].y);
  Line(points[3].x, points[3].y, points[1].x, points[1].y);
end;

procedure flagField(x, y : WORD);
var i : BYTE;
begin
  hiddenField(x, y);
  x := xTC(x); y := yTC(y);
  SetColor(RGBColor(145, 145, 145));
  SetFillStyle(SolidFill, RGBColor(145, 145, 145));

  // Field Outline
  SetColor(RGBColor(100, 100, 100));

  SetColor(RGBColor(0, 0, 0));
  SetFillStyle(SolidFill, RGBColor(0, 0, 0));
  // 1 stair
  FillRect(x + FIELD_SIZE SHR 3, y + FIELD_SIZE - FIELD_SIZE SHR 2 + FIELD_SIZE SHR 4, x + FIELD_SIZE - FIELD_SIZE SHR 3, y + FIELD_SIZE - FIELD_SIZE SHR 3 + FIELD_SIZE SHR 4);
  // 2 stair
  FillRect(x + FIELD_SIZE SHR 2, y + FIELD_SIZE - FIELD_SIZE SHR 2 + FIELD_SIZE SHR 4 - FIELD_SIZE SHR 3, x + FIELD_SIZE - FIELD_SIZE SHR 2, y + FIELD_SIZE - FIELD_SIZE SHR 2 + FIELD_SIZE SHR 4);
  
  // rod
  FillRect(x + FIELD_SIZE SHR 1 - FIELD_SIZE SHR 4, y + FIELD_SIZE SHR 1 - FIELD_SIZE SHR 3, x + FIELD_SIZE SHR 1 + FIELD_SIZE SHR 4, y + FIELD_SIZE - FIELD_SIZE SHR 2 + FIELD_SIZE SHR 4 - FIELD_SIZE SHR 3);
  
  // red flag
  FilledTriangle(x + FIELD_SIZE SHR 1 + FIELD_SIZE SHR 4, y + FIELD_SIZE SHR 4, x + FIELD_SIZE SHR 1 + FIELD_SIZE SHR 4, y + FIELD_SIZE SHR 1, RGBColor(255, 0, 0));
end;

procedure crossFlag(x, y : WORD);
begin
  x := xTC(x); y := yTC(y);
  // linie von links oben nach rechts unten
  RotatedRect(ROUND(x + FIELD_SIZE SHR 4), ROUND(y - FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), ROUND(x - FIELD_SIZE SHR 4) + FIELD_SIZE, ROUND(y + FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), 45, RGBColor(255, 0, 0)); 
  // linie von rechts oben nach links unten
  RotatedRect(ROUND(x - FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), ROUND(y + FIELD_SIZE SHR 4), ROUND(x + FIELD_SIZE SHR 4 + FIELD_SIZE SHR 1), ROUND(y - FIELD_SIZE SHR 4) + FIELD_SIZE, 45, RGBColor(255, 0, 0)); 
    
end;

procedure testVersionRedrawAll;
var x, y : BYTE;
    winDetection : WORD;
begin
  winDetection := 0;

  // läuft über alle Felder
  FOR y := 0 TO ROWS - 1 do begin
    FOR x := 0 TO COLUMNS - 1 do begin

      // Flaggen:
      IF (fieldData[x, y].isFlagged) then begin
        // normale Flagge
        flagField(x, y);
        inc(winDetection);

        // streicht flaggen durch
        IF (gameover) and (fieldData[x, y].number <> 9) then begin
          crossFlag(x, y);
        end;
      end ELSE begin

        // nicht geöffnetes Feld
        IF (not fieldData[x, y].isvisible) then begin
          hiddenField(x, y);
          inc(winDetection);
        end else begin

          // geöffnetes Feld
          numberField(x, y, fieldData[x, y].number)
        end;
      end;
    end;
  end;

  // win detection
  IF (winDetection = MINES) then won := true;
  WriteLn(winDetection, ' out of ', MINES, ' Mines');
end;

procedure MouseWaitForClick;
var mouseevent : MouseEventType;
begin
  REPEAT
    GetMouseEvent(mouseevent);
  UNTIL (mouseevent.action = MouseActionDown)
end;

procedure zeroSpreading(x, y : BYTE);
var spreadX, spreadY : INTEGER;
begin
  IF ((x >= 0) and (x <= COLUMNS - 1) and (y >= 0) and (y <= ROWS - 1)) then begin
      IF not fieldData[x, y].isvisible then begin
        IF fieldData[x, y].number <> 9 then fieldData[x, y].isvisible := true;
        IF fieldData[x, y].number = 0 then begin
        {
          FOR spreadY := -1 TO 1 DO
            FOR spreadX := -1 TO 1 DO
              zeroSpreading(x + spreadX, y + spreadY);
          }

          // Es funktioniert auch ohne loop also nicht ändern
          zeroSpreading(x - 1, y - 1);
          zeroSpreading(x, y - 1);
          zeroSpreading(x + 1, y - 1);
          zeroSpreading(x - 1, y);
          zeroSpreading(x + 1, y);
          zeroSpreading(x - 1, y + 1);
          zeroSpreading(x, y + 1);
          zeroSpreading(x + 1, y + 1);
        end;
      end;
  end;
end;

procedure generateMines(safeX, safeY : BYTE);
var x, y : BYTE;
  mineCount : WORD;
begin
  mineCount := 0;
  Randomize;
  while mineCount < MINES do
  begin
    x := Random(COLUMNS);
    y := Random(ROWS);
    
    // Überprüfen, ob die Position innerhalb des sicheren Bereichs liegt
    if (x >= safeX-1) and (x <= safeX+1) and (y >= safeY-1) and (y <= safeY+1) then
      Continue;
    
    // Überprüfen, ob die Position bereits eine Bombe enthält
    if fieldData[x, y].number = 9 then
      Continue;

    // Bombe platzieren
    fieldData[x, y].number := 9;
    Inc(mineCount);
  end;
end;

procedure calculateNumbers;
var
  x, y : BYTE;
  i, j : INTEGER;
begin
  // läuft durchs ganze Feld
  FOR x := 0 to COLUMNS - 1 DO
    FOR y := 0 to ROWS - 1 DO begin
    
      // Überspringt berechnung bei Bomben
      IF fieldData[x, y].number = 9 THEN Continue;

      // Berechnung der Zahl
      FOR i := -1 to 1 DO begin
        FOR j := -1 to 1 DO begin
          IF (x + i >= 0) and (x + i < COLUMNS) and (y + j >= 0) and (y + j < ROWS) and (fieldData[x + i, y + j].number = 9) THEN begin
            Inc(fieldData[x, y].number);
          end;
        end;
      end;
    end;
end;

procedure chord(x, y : BYTE);
var mineCount, flagCount : BYTE;
    indexX, indexY : INTEGER;
    notFoundBomb : BOOLEAN;
begin
  mineCount := 0;
  flagCount := 0;
  notFoundBomb := false;


  FOR indexY := -1 TO 1 DO begin
    FOR indexX := -1 TO 1 DO begin
      IF (x + indexX >= 0) and (x + indexX <= COLUMNS - 1) and ( y + indexY >= 0) and (y + indexY <= ROWS - 1) then begin

        // Berechnet anzahl der Flagen um zu schauen ob chording möglich ist
        IF (fieldData[x + indexX, y + indexY].isFlagged) then begin
          inc(flagCount);
        end else begin

        // Wenn eine bombe gechorded wird wird nur sie ausgegraben der rest nicht.
          IF (fieldData[x + indexX, y + indexY].number = 9) and (not fieldData[x + indexX, y + indexY].isFlagged) then begin
            notFoundBomb := true;
          end;
        end;
      end;
    end;
  end;
  
  // Getestet ob chording möglich ist
  IF flagCount = fieldData[x, y].number then begin
    FOR indexY := -1 TO 1 DO begin
      FOR indexX := -1 TO 1 DO begin

        // beendet das spiel wenn bombe ausgegraben wird
        IF notFoundBomb then begin
          gameover := true;
          EXIT;
        end;

        // checks if in field & ob noch nicht ausgegraben
        IF (x + indexX >= 0) and (x + indexX <= COLUMNS - 1) and ( y + indexY >= 0) and (y + indexY <= ROWS - 1) and (not fieldData[x + indexX, y + indexY].isvisible) then begin
          
          // TODO: zeroSpreading hat vll einen bug und funktioniert bei chording nicht. 
          zeroSpreading(x + indexX, y + indexY);
          fieldData[x + indexX, y + indexY].isvisible := true;
        end;
      end;
    end;
  end;

  // updatet das fenster
  testVersionRedrawAll;
end;

procedure MouseClick;
var x, y : REAL;
    mouseX, mouseY : BYTE;
    mouseXREAL, mouseYREAL : REAL;
begin
MouseWaitForClick;
  x := GetMouseX;
  Y := GetMouseY;

  // Berechnet auf welchem Feld Maus ist
  mouseXREAL := (x-25)/FIELD_SIZE + 0.5;
  mouseYREAL := (y - INFO_SCREEN)/FIELD_SIZE + 0.5;
  mouseX := ROUND(mouseXREAL) - 1;
  mouseY := ROUND(mouseYREAL - 1);

  WriteLn('Mouse Cords bei: (', mouseX, '|', mouseY, ')');

  // Linke Maustaste
  if ((GetAsyncKeyState(VK_LBUTTON) <> 0 ) and (not fieldData[mouseX, mouseY].isFlagged)) then begin
          
    // Schaut ob maus im Spielfeld ist
    // TODO: hitboxen funktionieren außerhalb + am rand des spielfeldes nicht richtig
    IF (mouseX >= 0) and (mouseX <= COLUMNS) and ( mouseY >= 0) and (mouseY <= ROWS) then begin

      // generiert Minen wenn noch keine da sind
      IF (not generatedMines) then begin
        generateMines(mouseX, mouseY);
        generatedMines := true;
        calculateNumbers;
      end;

      zeroSpreading(mouseX, mouseY);

      // Lose detection
      IF fieldData[mouseX, mouseY].number = 9 then gameover := true;

      fieldData[mouseX, mouseY].isvisible := true;
      testVersionRedrawAll;
    end;
  end else begin

    // rechte Maustaste
    IF GetAsyncKeyState(VK_RBUTTON) <> 0 then begin

      // plaziert flagge
      IF ( (not fieldData[mouseX, mouseY].isvisible) and (not fieldData[mouseX, mouseY].isFlagged) ) then begin
        fieldData[mouseX, mouseY].isFlagged := true;
       
      end ELSE begin

        // entfernt flagge
        IF ( (not fieldData[mouseX, mouseY].isvisible) and (fieldData[mouseX, mouseY].isFlagged) ) then begin
          fieldData[mouseX, mouseY].isFlagged := false;
        end;
      end;
      testVersionRedrawAll;
    end;
  end;

  // Beide Maustasten
  IF ( (GetAsyncKeyState(VK_RBUTTON) <> 0) and (GetAsyncKeyState(VK_LBUTTON) <> 0) and (fieldData[mouseX, mouseY].number >= 0) and (fieldData[mouseX, mouseY].number <= 8) and (fieldData[mouseX, mouseY].isvisible)) then begin
    chord(mouseX, mouseY);
  end;
end;

// 0 -> Feld 0
// 1 -> Feld 1
// 1 -> Feld 2
// 3 -> Feld 3
// 4 -> Feld 4
// 5 -> Feld 5
// 6 -> Feld 6
// 7 -> Feld 7
// 8 -> Feld 8
// 9 -> Bomb

var gd, gm            : INTEGER;
    r, g, b           : WORD;
    x, y              : WORD;
    mouseevent        : MouseEventType;
    safeX, safeY      : BYTE;

begin
  { Auf den Graphikmodus umschalten}
  SetWindowSize(FIELD_SIZE * COLUMNS + 50, FIELD_SIZE * ROWS + 25 + INFO_SCREEN);
  gd := nopalette; gm := mCustom;
  InitGraph( gd, gm, 'Minesweeper');
  { Grafik-Arbeit ANFANG }
  background;

  testVersionRedrawAll;
  gameover := false;
  REPEAT
    MouseClick;
  UNTIL gameover OR won;
  
  // zeigt alle bomben wenn tot
  IF (gameover) then FOR y := 0 TO ROWS - 1 do FOR x := 0 TO COLUMNS - 1 do IF fieldData[x, y].number = 9 THEN begin
    fieldData[x, y].isvisible := true;

    // fixed komischen bug dass man gewinnt bei settings die ganzes feld außer kleinen bereich zu bomben macht zb: 10x10 mit 91 Bomben
    won := false;
  end;
  
  // plaziert alle flaggen wenn gewonnen
  IF (won) then FOR y := 0 TO ROWS - 1 do FOR x := 0 TO COLUMNS - 1 do IF fieldData[x, y].number = 9 THEN fieldData[x, y].isFlagged := true;
    testVersionRedrawAll;

  // Konsolen nachricht
  IF (won) then WriteLn('You won!');
  IF (gameover) then WriteLn('You lost!');

  { Grafik-Arbeit ENDE }
  REPEAT
    Delay(0);
  UNTIL CloseGraphRequest;
end.
