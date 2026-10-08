**KOR**, [ENG](./README-ENG.md)

# `ropas-poster` 클래스
## 설명

서울대학교 프로그래밍 연구실(ROPAS)을 위한 포스터 양식입니다.

### 포스터 구성

포스터는 머리[header]와 몸통[body]으로 구성됩니다.

#### 머리

머리에는 제목[title], 부제[subtitle], 저자명[author], 소속명[institute]이
출력됩니다.

#### 몸통

몸통에는 로고와 최상위 블록이 출력됩니다.

로고는 순서대로 일렬로 출력됩니다. 로고의 개수가 많아 서로 겹치는 로고가 생기면
여러 줄로 나뉘어 출력됩니다.

블록은 블록 제목을 가질 수 있고, 그 아래에 본문이나 격자가 들어갑니다. 격자에는
여러 블록을 원하는 위치에 배치할 수 있습니다.

## 기능
### 패키지

`ropas-poster` 클래스가 불러오는 패키지 목록입니다. 해당 패키지는 따로 불러오지
않고 사용할 수 있습니다.

모든 엔진에서 직접 불러오는 패키지는 다음과 같습니다.

- `amsmath`
- `amssymb`
- `amsthm`
- `booktabs`
- `caption`
- `caption3`
- `comment`
- `etoolbox`
- `geometry`
- `graphicx`
- `hyperref`
- `libertine`
- `microtype`
- `xcolor`

엔진에 따라 추가로 직접 불러오는 패키지는 다음과 같습니다.

- pdfLaTeX: `cmap`, `fontenc`, `newtxmath`, `zi4`
- XeLaTeX, LuaLaTeX: `unicode-math`

### 클래스 옵션

클래스를 불러올 때 사용할 수 있는 옵션입니다.

- `paper`

  종이 규격을 설정하는 옵션입니다. 3가지 유형의 값이 가능합니다. 기본값은
  `A0`입니다.

  - `<paper>` 유형

    규격 이름으로 설정하는 방법입니다. 종이 방향은 세로로 긴 방향으로
    설정됩니다. 가능한 규격 이름은 다음과 같습니다.

    | 이름  | 가로     | 세로     |
    | ----- | -------- | -------- |
    | `A0`  | `841mm`  | `1189mm` |
    | `A1`  | `594mm`  | `841mm`  |
    | `A2`  | `420mm`  | `594mm`  |
    | `A3`  | `297mm`  | `420mm`  |
    | `A4`  | `210mm`  | `297mm`  |
    | `A5`  | `148mm`  | `210mm`  |
    | `A6`  | `105mm`  | `148mm`  |
    | `A7`  | `74mm`   | `105mm`  |
    | `A8`  | `52mm`   | `74mm`   |
    | `A9`  | `37mm`   | `52mm`   |
    | `A10` | `26mm`   | `37mm`   |
    | `4A0` | `1682mm` | `2378mm` |
    | `2A0` | `1189mm` | `1682mm` |
    | `B0`  | `1000mm` | `1414mm` |
    | `B1`  | `707mm`  | `1000mm` |
    | `B2`  | `500mm`  | `707mm`  |
    | `B3`  | `353mm`  | `500mm`  |
    | `B4`  | `250mm`  | `353mm`  |
    | `B5`  | `176mm`  | `250mm`  |
    | `B6`  | `125mm`  | `176mm`  |
    | `B7`  | `88mm`   | `125mm`  |
    | `B8`  | `62mm`   | `88mm`   |
    | `B9`  | `44mm`   | `62mm`   |
    | `B10` | `31mm`   | `44mm`   |

  - `{<paper>,<orientation>}` 유형

    규격 이름과 방향으로 설정하는 방법입니다. 가능한 규격 이름은 위와 같고,
    방향으로는 `portrait`(세로로 긴 방향)와 `landscape`(가로로 긴 방향)이
    가능합니다.

  - `{<width>,<height>}` 유형

    가로세로 길이를 직접 설정하는 방법입니다. 두 길이 모두 양의 길이여야 합니다.

- `theme`

  포스터 테마를 설정하는 옵션입니다. 가능한 값은 다음과 같습니다. 기본값은
  `default`입니다.

  - `default`: 기본 테마입니다.

### 명령어

클래스에서 정의하는 명령어입니다. 기본적으로는 LaTeX 내장 명령어도 사용할 수
있지만, 다음 내장 명령어는 지원하지 않습니다. 사용하더라도 클래스에서 오류를
출력하지는 않지만 출력 결과가 올바르지 않을 수도 있습니다.

- `\bibitem`
- `\bibliography`
- `\bibliographystyle`
- `\cite`
- `\cleardoublepage`
- `\clearpage`
- `\date`
- `\enlargethispage`
- `\enlargethispage*`
- `\flushbottom`
- `\fontsize`
- `\glossary`
- `\include`
- `\includeonly`
- `\index`
- `\linespread`
- `\makeindex`
- `\makeglossary`
- `\marginpar`
- `\newpage`
- `\nocite`
- `\nopagebreak`
- `\onecolumn`
- `\pagebreak`
- `\pagenumbering`
- `\pagestyle`
- `\raggedbottom`
- `\selectfont`
- `\thanks`
- `\thispagestyle`
- `\twocolumn`

#### 사전 명령어

`document` 환경 시작 전에 사용할 수 있는 명령어입니다.

##### `\posterDefineTheme`

새 테마를 정의하는 명령어입니다.

```latex
\posterDefineTheme{<name>}[<base>]{<options>}
```

- `name`

  테마 이름입니다. 로마자, 숫자와 `-`로 구성된 비어있지 않은 문자열이어야 하고,
  이미 정의된 테마의 이름은 사용할 수 없습니다.

- `base`

  기반 테마 이름입니다. 공백이거나 이미 정의된 테마의 이름이어야 합니다.
  공백이면 `default` 테마를 기반으로 합니다.

- `options`

  - `paper-margin-side`

    종이 옆쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

  - `header-background`

    머리 배경을 생성하는 명령어입니다. 영역의 너비와 높이를 각각 중괄호로 감싸
    해당 순서로 받아 머리 배경을 생성하는 명령어 이름이어야 합니다.

  - `header-margin-top`

    머리 위쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

  - `header-margin-bottom`

    머리 아래쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

  - `header-leading`

    머리의 줄 간격입니다. 음이 아닌 길이 값이어야 합니다.

  - `title-size`

    제목 크기입니다. 양의 길이 값이어야 합니다.

  - `title-color`

    제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

  - `subtitle-size`

    부제 크기입니다. 양의 길이 값이어야 합니다.

  - `subtitle-color`

    부제 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

  - `author-size`

    저자명 크기입니다. 양의 길이 값이어야 합니다.

  - `author-color`

    저자명 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

  - `institute-size`

    소속명 크기입니다. 양의 길이 값이어야 합니다.

  - `institute-color`

    소속명 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

  - `body-background`

    몸통 배경을 생성하는 명령어입니다. 영역의 너비와 높이를 각각 중괄호로 감싸
    해당 순서로 받아 몸통 배경을 생성하는 명령어 이름이어야 합니다.

  - `body-margin-top`

    몸통 위쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다. 로고와 블록 사이,
    두 로고 줄 사이 간격으로도 쓰입니다.

  - `body-margin-bottom`

    몸통 아래쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

  - `logo-height`

    로고 높이입니다. 양의 길이 값이어야 합니다.

  - `block-sep`

    블록 사이 간격입니다. 음이 아닌 길이 값이어야 합니다.

  - `block-color`

    블록 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

  - `block-corner-radius`

    블록 모서리 반지름입니다. 음이 아닌 길이 값이어야 합니다.

  - `block-margin`

    블록 내부 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

  - `block-align`

    블록 내부 본문의 수직 정렬입니다. `top`, `center`, `bottom` 중 하나여야
    합니다.

  - `block-column-count`

    블록 내부 본문 열의 개수입니다. 양의 정수 값이어야 합니다.

  - `block-column-sep`

    블록 내부 본문 열 사이 간격입니다. 음이 아닌 길이 값이어야 합니다.

  - `block-leading`

    블록 내부 본문 줄 간격입니다. 음이 아닌 길이 값이어야 합니다.

  - `block-paragraph-sep`

    블록 내부 단락 사이 간격입니다. 음이 아닌 길이 값이어야 합니다.

  - `block-paragraph-indent`

    블록 내부 단락 들여쓰기 너비입니다. 음이 아닌 길이 값이어야 합니다.

  - `blocktitle-size`

    블록 제목 크기입니다. 양의 길이 값이어야 합니다.

  - `blocktitle-color`

    블록 제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

  - `sectiontitle-size`

    절 제목 크기입니다. 양의 길이 값이어야 합니다.

  - `sectiontitle-color`

    절 제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

  - `text-size`

    본문 크기입니다. 양의 길이 값이어야 합니다.

  - `text-color`

    본문 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\posterSetPaperSize`

종이 규격을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 종이의 가로
길이와 세로 길이를 주어진 규격으로 설정합니다.

```latex
\posterSetPaperSize[<orientation>]{<paper>}
```

- `orientation`

  종이 방향입니다. `portrait`(세로로 긴 방향), `landscape`(가로로 긴 방향) 중
  하나여야 합니다. 기본값은 `portrait`입니다.

- `paper`

  종이 규격 이름입니다. 가능한 규격 이름은 `paper` 클래스 옵션에서와 같습니다.

```latex
\posterSetPaperSize{<width>,<height>}
```

- `width`

  종이의 가로 길이입니다. 양의 길이 값이어야 합니다.

- `height`

  종이의 세로 길이입니다. 양의 길이 값이어야 합니다.

##### `\posterSetPaperWidth`

종이의 가로 길이를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 종이의
가로 길이를 주어진 값으로 설정합니다.

```latex
\posterSetPaperWidth{<width>}
```

- `width`

  종이의 가로 길이입니다. 양의 길이 값이어야 합니다.

##### `\posterSetPaperHeight`

종이의 세로 길이를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 종이의
세로 길이를 주어진 값으로 설정합니다.

```latex
\posterSetPaperHeight{<height>}
```

- `height`

  종이의 세로 길이입니다. 양의 길이 값이어야 합니다.

##### `\posterSetTheme`

포스터 테마를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 각 속성을
주어진 테마에서 정의된 값으로 설정합니다.

```latex
\posterSetTheme{<theme>}
```

- `theme`

  테마 이름입니다. 해당 명령어가 실행되기 전에 정의된 테마 이름이어야 합니다.

##### `\posterSetPaperMarginSide`

종이 옆쪽 여백 너비를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 여백
너비를 주어진 값으로 설정합니다.

```latex
\posterSetPaperMarginSide{<margin>}
```

- `margin`

  종이 옆쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetHeaderBackground`

머리 배경을 생성하는 명령어를 설정하는 명령어입니다. 해당 명령어를 호출하는
순간에 명령어를 주어진 값으로 설정합니다.

```latex
\posterSetHeaderBackground{<command-name>}
```

- `command-name`

  머리 배경을 생성하는 명령어입니다. 영역의 너비와 높이를 각각 중괄호로 감싸
  해당 순서로 받아 머리 배경을 생성하는 명령어 이름이어야 합니다.

##### `\posterSetHeaderMarginTop`

머리 위쪽 여백 너비를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 여백
너비를 주어진 값으로 설정합니다.

```latex
\posterSetHeaderMarginTop{<margin>}
```

- `margin`

  머리 위쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetHeaderMarginBottom`

머리 아래쪽 여백 너비를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에
여백 너비를 주어진 값으로 설정합니다.

```latex
\posterSetHeaderMarginBottom{<margin>}
```

- `margin`

  머리 아래쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetHeaderLeading`

머리의 줄 간격을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 줄 간격을
주어진 값으로 설정합니다.

```latex
\posterSetHeaderLeading{<leading>}
```

- `leading`

  머리의 줄 간격입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetTitleSize`

제목 크기를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 크기를 주어진
값으로 설정합니다.

```latex
\posterSetTitleSize{<size>}
```

- `size`

  제목 크기입니다. 양의 길이 값이어야 합니다.

##### `\posterSetTitleColor`

제목 색을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 색을 주어진
값으로 설정합니다.

```latex
\posterSetTitleColor{<color>}
```

- `color`

  제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\posterSetSubtitleSize`

부제 크기를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 크기를 주어진
값으로 설정합니다.

```latex
\posterSetSubtitleSize{<size>}
```

- `size`

  부제 크기입니다. 양의 길이 값이어야 합니다.

##### `\posterSetSubtitleColor`

부제 색을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 색을 주어진
값으로 설정합니다.

```latex
\posterSetSubtitleColor{<color>}
```

- `color`

  부제 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\posterSetAuthorSize`

저자명 크기를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 크기를 주어진
값으로 설정합니다.

```latex
\posterSetAuthorSize{<size>}
```

- `size`

  저자명 크기입니다. 양의 길이 값이어야 합니다.

##### `\posterSetAuthorColor`

저자명 색을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 색을 주어진
값으로 설정합니다.

```latex
\posterSetAuthorColor{<color>}
```

- `color`

  저자명 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\posterSetInstituteSize`

소속명 크기를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 크기를 주어진
값으로 설정합니다.

```latex
\posterSetInstituteSize{<size>}
```

- `size`

  소속명 크기입니다. 양의 길이 값이어야 합니다.

##### `\posterSetInstituteColor`

소속명 색을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 색을 주어진
값으로 설정합니다.

```latex
\posterSetInstituteColor{<color>}
```

- `color`

  소속명 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\posterSetBodyBackground`

몸통 배경을 생성하는 명령어를 설정하는 명령어입니다. 해당 명령어를 호출하는
순간에 명령어를 주어진 값으로 설정합니다.

```latex
\posterSetBodyBackground{<command-name>}
```

- `command-name`

  몸통 배경을 생성하는 명령어입니다. 영역의 너비와 높이를 각각 중괄호로 감싸
  해당 순서로 받아 몸통 배경을 생성하는 명령어 이름이어야 합니다.

##### `\posterSetBodyMarginTop`

몸통 위쪽 여백 너비를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 여백
너비를 주어진 값으로 설정합니다.

```latex
\posterSetBodyMarginTop{<margin>}
```

- `margin`

  몸통 위쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다. 로고와 블록 사이,
  두 로고 줄 사이 간격으로도 쓰입니다.

##### `\posterSetBodyMarginBottom`

몸통 아래쪽 여백 너비를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에
여백 너비를 주어진 값으로 설정합니다.

```latex
\posterSetBodyMarginBottom{<margin>}
```

- `margin`

  몸통 아래쪽 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetLogoHeight`

로고 높이를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 높이를 주어진
값으로 설정합니다.

```latex
\posterSetLogoHeight{<height>}
```

- `height`

  로고 높이입니다. 양의 길이 값이어야 합니다.

##### `\posterSetBlockSep`

블록 사이 간격을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 간격을
주어진 값으로 설정합니다.

```latex
\posterSetBlockSep{<sep>}
```

- `sep`

  블록 사이 간격입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetBlockColor`

블록 색을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 색을 주어진
값으로 설정합니다.

```latex
\posterSetBlockColor{<color>}
```

- `color`

  블록 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\posterSetBlockCornerRadius`

블록 모서리 반지름을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에
반지름을 주어진 값으로 설정합니다.

```latex
\posterSetBlockCornerRadius{<radius>}
```

- `radius`

  블록 모서리 반지름입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetBlockMargin`

블록 내부 여백 너비를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 여백
너비를 주어진 값으로 설정합니다.

```latex
\posterSetBlockMargin{<margin>}
```

- `margin`

  블록 내부 여백 너비입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetBlockAlign`

블록 내부 본문의 수직 정렬을 설정하는 명령어입니다. 해당 명령어를 호출하는
순간에 정렬을 주어진 값으로 설정합니다.

```latex
\posterSetBlockAlign{<align>}
```

- `align`

  블록 내부 본문의 수직 정렬입니다. `top`, `center`, `bottom` 중 하나여야
  합니다.

##### `\posterSetBlockColumnCount`

블록 내부 본문 열의 개수를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에
개수를 주어진 값으로 설정합니다.

```latex
\posterSetBlockColumnCount{<count>}
```

- `count`

  블록 내부 본문 열의 개수입니다. 양의 정수 값이어야 합니다.

##### `\posterSetBlockColumnSep`

블록 내부 본문 열 사이 간격을 설정하는 명령어입니다. 해당 명령어를 호출하는
순간에 간격을 주어진 값으로 설정합니다.

```latex
\posterSetBlockColumnSep{<sep>}
```

- `sep`

  블록 내부 본문 열 사이 간격입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetBlockLeading`

블록 내부 본문 줄 간격을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 줄
간격을 주어진 값으로 설정합니다.

```latex
\posterSetBlockLeading{<leading>}
```

- `leading`

  블록 내부 본문 줄 간격입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetBlockParagraphSep`

블록 내부 단락 사이 간격을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에
간격을 주어진 값으로 설정합니다.

```latex
\posterSetBlockParagraphSep{<sep>}
```

- `sep`

  블록 내부 단락 사이 간격입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetBlockParagraphIndent`

블록 내부 단락 들여쓰기 너비를 설정하는 명령어입니다. 해당 명령어를 호출하는
순간에 너비를 주어진 값으로 설정합니다.

```latex
\posterSetBlockParagraphIndent{<indent>}
```

- `indent`

  블록 내부 단락 들여쓰기 너비입니다. 음이 아닌 길이 값이어야 합니다.

##### `\posterSetBlocktitleSize`

블록 제목 크기를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 크기를
주어진 값으로 설정합니다.

```latex
\posterSetBlocktitleSize{<size>}
```

- `size`

  블록 제목 크기입니다. 양의 길이 값이어야 합니다.

##### `\posterSetBlocktitleColor`

블록 제목 색을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 색을 주어진
값으로 설정합니다.

```latex
\posterSetBlocktitleColor{<color>}
```

- `color`

  블록 제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\posterSetSectiontitleSize`

절 제목 크기를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 크기를
주어진 값으로 설정합니다.

```latex
\posterSetSectiontitleSize{<size>}
```

- `size`

  절 제목 크기입니다. 양의 길이 값이어야 합니다.

##### `\posterSetSectiontitleColor`

절 제목 색을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 색을 주어진
값으로 설정합니다.

```latex
\posterSetSectiontitleColor{<color>}
```

- `color`

  절 제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\posterSetTextSize`

본문 크기를 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 크기를 주어진
값으로 설정합니다.

```latex
\posterSetTextSize{<size>}
```

- `size`

  본문 크기입니다. 양의 길이 값이어야 합니다.

##### `\posterSetTextColor`

본문 색을 설정하는 명령어입니다. 해당 명령어를 호출하는 순간에 색을 주어진
값으로 설정합니다.

```latex
\posterSetTextColor{<color>}
```

- `color`

  본문 색입니다. `xcolor` 패키지 색 이름이어야 합니다.

##### `\title`

제목을 설정하는 명령어입니다. 해당 명령어를 여러 번 호출하면 가장 마지막에
호출한 명령어의 제목으로 설정됩니다.

```latex
\title{<title>}
```

- `title`

  제목입니다. 각주 명령이 포함되면 오류를 출력합니다. 설정하기 전 값은 빈
  문자열입니다.

##### `\subtitle`

부제를 설정하는 명령어입니다. 해당 명령어를 여러 번 호출하면 가장 마지막에
호출한 명령어의 부제로 설정됩니다.

```latex
\subtitle{<subtitle>}
```

- `subtitle`

  부제입니다. 각주 명령이 포함되면 오류를 출력합니다. 설정하기 전 값은 빈
  문자열입니다.

##### `\author`

저자명을 설정하는 명령어입니다. 해당 명령어를 부를 때마다 저자명이 누적됩니다.

```latex
\author{<authors>}
```

- `authors`

  저자명입니다. 각주 명령이 포함되면 오류를 출력합니다. 여러 저자명은 각각
  `\and`로 구분합니다. 설정하기 전 값은 빈 리스트입니다.

##### `\institute`

소속명을 설정하는 명령어입니다. 해당 명령어를 부를 때마다 소속명이 누적됩니다.

```latex
\institute{<institutes>}
```

- `institutes`

  소속명입니다. 각주 명령이 포함되면 오류를 출력합니다. 여러 소속명은 각각
  `\and`로 구분합니다. 설정하기 전 값은 빈 리스트입니다.

##### `\logo`

로고를 설정하는 명령어입니다. 해당 명령어를 부를 때마다 로고가 누적됩니다.

```latex
\logo{<logos>}
```

- `logos`

  로고입니다. 쉼표로 구분된 파일명이어야 합니다. 쉼표가 들어간 파일명은 중괄호로
  감싸 입력할 수 있습니다. JPEG, PDF, PNG 파일 양식을 사용할 수 있습니다.
  설정하기 전 값은 빈 리스트입니다.

#### 문서 명령어

`document` 환경 내에서 사용할 수 있는 명령어입니다.

##### `\blocktitle`

블록 제목을 설정하는 명령어입니다.

`\blocktitle` 명령어는 `document` 환경이나 `posterblock` 환경 내에서 최대 한 번
호출할 수 있으며, 호출 위치는 해당 환경 내에서 맨처음이어야 합니다.

```latex
\blocktitle{<title>}
```

- `title`

  블록 제목입니다. 설정하기 전 값은 빈 문자열입니다.

##### `\sectiontitle`

절 제목을 설정하는 명령어입니다.

`\sectiontitle` 명령어는 내부에 `postergrid` 환경을 직접 포함하지 않는
`document` 환경이나 `posterblock` 환경 내에서 호출할 수 있습니다.

```latex
\sectiontitle{<title>}
```

- `title`

  절 제목입니다.

##### `\columnbreak`

여러 본문 열을 가진 블록의 본문에서 내용을 다음 열로 강제로 넘기는 명령어입니다.

`\columnbreak` 명령어는 내부에 `postergrid` 환경을 직접 포함하지 않는 `document`
환경이나 `posterblock` 환경 내에서 호출할 수 있습니다. 블록의 마지막 본문 열에
위치한 명령어는 무시됩니다.

##### `\tiny`

글꼴 크기를 설정 값의 0.6배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다. 설정
값이 바뀌지는 않습니다.

##### `\scriptsize`

글꼴 크기를 설정 값의 0.7배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다. 설정
값이 바뀌지는 않습니다.

##### `\footnotesize`

글꼴 크기를 설정 값의 0.8배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다. 설정
값이 바뀌지는 않습니다.

##### `\small`

글꼴 크기를 설정 값의 0.9배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다. 설정
값이 바뀌지는 않습니다.

##### `\normalsize`

글꼴 크기를 설정 값으로 조정합니다. 줄 간격도 같은 비율로 조정됩니다.

##### `\large`

글꼴 크기를 설정 값의 1.095배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다.
설정 값이 바뀌지는 않습니다.

##### `\Large`

글꼴 크기를 설정 값의 1.2배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다. 설정
값이 바뀌지는 않습니다.

##### `\LARGE`

글꼴 크기를 설정 값의 1.44배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다.
설정 값이 바뀌지는 않습니다.

##### `\huge`

글꼴 크기를 설정 값의 1.728배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다.
설정 값이 바뀌지는 않습니다.

##### `\Huge`

글꼴 크기를 설정 값의 2.074배로 조정합니다. 줄 간격도 같은 비율로 조정됩니다.
설정 값이 바뀌지는 않습니다.

### 환경

`document` 환경 내에서 사용할 수 있는 환경입니다. LaTeX 내장 환경과 `amsmath`,
`amsthm` 패키지에서 정의된 환경도 사용할 수 있습니다.

#### 포스터 구조 환경

포스터 구조를 정하는 환경입니다. 환경의 구조를 요약하면 다음과 같습니다.

- `postergrid` 환경

  - `posterblock` 환경: 영역이 겹치지 않아야 함.
  - `posterblock*` 환경: 영역이 겹치지 않아야 함.

- `posterblock` 환경(본문 유형)

  - `\blocktitle` 명령어: 최대 하나. 있으면 환경 맨 처음에 위치.
  - `\sectiontitle` 명령어와 본문

- `posterblock` 환경(격자 유형)

  - `\blocktitle` 명령어: 최대 하나. 있으면 환경 맨 처음에 위치.
  - `postergrid` 환경: 최대 하나.

- `posterblock*` 환경

  - `postergrid` 환경: 최대 하나.

- `document` 환경(본문 유형)

  - `\blocktitle` 명령어: 최대 하나. 있으면 환경 맨 처음에 위치.
  - `\sectiontitle` 명령어와 본문

- `document` 환경(격자 유형)

  - `\blocktitle` 명령어: 최대 하나. 있으면 환경 맨 처음에 위치.
  - `postergrid` 환경: 최대 하나.

##### `postergrid`

격자 환경입니다. 블록을 원하는 형태로 나눌 때 사용됩니다.

`postergrid` 환경은 블록 제목 외 다른 내용이 없는 `document` 환경, `posterblock`
환경이나 `posterblock*` 환경 내에서 최대 한 번 정의될 수 있습니다. `postergrid`
환경은 `posterblock` 환경이나 `posterblock*` 환경만을 직접 포함할 수 있습니다.

```latex
\begin{postergrid}{<row-count>}{<col-count>}[<options>]
  ...
\end{postergrid}
```

- `row-count`

  행의 개수입니다. 양의 정수 값이어야 합니다.

- `col-count`

  열의 개수입니다. 양의 정수 값이어야 합니다.

- `options`

  - `row-ratio`

    행 높이 비입니다. 2가지 유형의 값이 가능합니다. 기본값은 `default`입니다.

    - `default`

      기본값입니다. `{auto,auto,...,auto}`와 같습니다.

    - `{<H1>,<H2>,...,<Hn>}` 유형

      각 행의 높이를 비로 표현하는 방법입니다. 각 값으로는 양의 정수 값, `auto`,
      `min`이 가능합니다. `min`은 내용을 출력하기 위해 필요한 최소의 높이를
      뜻하고, `auto`는 다른 행까지 참고해 적당한 높이로 정해집니다. 양의 정수
      값은 그대로 행 높이의 비를 뜻합니다.

  - `col-ratio`

    열 너비 비입니다. 2가지 유형의 값이 가능합니다. 기본값은 `default`입니다.

    - `default`

      기본값입니다. `{1,1,...,1}`과 같습니다.

    - `{<W1>,<W2>,...,<Wn>}` 유형

      각 열의 너비를 비로 표현하는 방법입니다. 각 값으로는 양의 정수 값만이
      가능합니다. 이 값은 그대로 열 너비의 비가 됩니다.

  - `line-width`

    격자 내 블록을 구분하는 선의 두께입니다. 음이 아닌 길이 값이어야 합니다.
    기본값은 `0mm`입니다. 이 값은 격자 내부의 선에만 영향을 줍니다.

  - `line-color`

    격자 내 블록을 구분하는 선의 색입니다. `xcolor` 패키지 색 이름이어야 합니다.
    기본값은 `black`입니다. 이 값은 격자 내부의 선에만 영향을 줍니다.

  - `block-sep`

    블록 사이 간격입니다. 음이 아닌 길이 값이어야 합니다. 기본값은 가장 가까운
    상위 환경의 `block-sep` 값입니다. 이 값은 격자 내부의 블록 사이 간격에만
    영향을 줍니다.

  - `block-color`

    블록 색입니다. `xcolor` 패키지 색 이름이어야 합니다. 기본값은 가장 가까운
    상위 환경의 `block-color` 값입니다.

  - `block-corner-radius`

    블록 모서리 반지름입니다. 음이 아닌 길이 값이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `block-corner-radius` 값입니다.

  - `block-margin`

    블록 내부 여백 너비입니다. 음이 아닌 길이 값이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `block-margin` 값입니다.

  - `block-align`

    블록 내부 본문의 수직 정렬입니다. `top`, `center`, `bottom` 중 하나여야
    합니다. 기본값은 가장 가까운 상위 환경의 `block-align` 값입니다.

  - `block-column-count`

    블록 내부 본문 열의 개수입니다. 양의 정수 값이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `block-column-count` 값입니다.

  - `block-column-sep`

    블록 내부 본문 열 사이 간격입니다. 음이 아닌 길이 값이어야 합니다. 기본값은
    가장 가까운 상위 환경의 `block-column-sep` 값입니다.

  - `block-leading`

    블록 내부 본문 줄 간격입니다. 음이 아닌 길이 값이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `block-leading` 값입니다.

  - `block-paragraph-sep`

    블록 내부 단락 사이 간격입니다. 음이 아닌 길이 값이어야 합니다. 기본값은
    가장 가까운 상위 환경의 `block-paragraph-sep` 값입니다.

  - `block-paragraph-indent`

    블록 내부 단락 들여쓰기 너비입니다. 음이 아닌 길이 값이어야 합니다. 기본값은
    가장 가까운 상위 환경의 `block-paragraph-indent` 값입니다.

  - `blocktitle-size`

    블록 제목 크기입니다. 양의 길이 값이어야 합니다. 기본값은 가장 가까운 상위
    환경의 `blocktitle-size` 값입니다.

  - `blocktitle-color`

    블록 제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `blocktitle-color` 값입니다.

  - `sectiontitle-size`

    절 제목 크기입니다. 양의 길이 값이어야 합니다. 기본값은 가장 가까운 상위
    환경의 `sectiontitle-size` 값입니다.

  - `sectiontitle-color`

    절 제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다. 기본값은 가장 가까운
    상위 환경의 `sectiontitle-color` 값입니다.

  - `text-size`

    본문 크기입니다. 양의 길이 값이어야 합니다. 기본값은 가장 가까운 상위 환경의
    `text-size` 값입니다.

  - `text-color`

    본문 색입니다. `xcolor` 패키지 색 이름이어야 합니다. 기본값은 가장 가까운
    상위 환경의 `text-color` 값입니다.

##### `posterblock`

블록 환경입니다. 내부에 본문이나 격자를 가질 수 있습니다.

`posterblock` 환경은 `postergrid` 환경 내에서 정의될 수 있습니다. `postergrid`
환경 내 `posterblock` 환경과 `posterblock*` 환경끼리는 차지하는 영역이 겹치지
않아야 합니다. `posterblock` 환경은 다음 2가지 유형이 가능합니다.

- 본문 유형

  본문 내용이 들어간 유형입니다. 블록 제목은 최대 하나 있을 수 있으며, 절
  제목에는 제한이 없습니다.

- 격자 유형

  `postergrid` 환경이 들어간 유형입니다. 블록 제목은 최대 하나 있을 수 있으며,
  절 제목이나 다른 내용은 들어갈 수 없습니다.

```latex
\begin{posterblock}{<row>}{<col>}[<options>]
  ...
\end{posterblock}
```

- `row`

  행의 위치입니다. 2가지 유형의 값이 가능합니다.

  - `<r>` 유형

    양의 정수 하나로 위치를 나타내는 방법입니다. 양의 정수 값이어야 하고 상위
    `postergrid` 환경의 행의 개수보다 작거나 같아야 합니다.

  - `<r1>-<r2>` 유형

    양의 정수 두 개로 위치를 나타내는 방법입니다. 각 값은 양의 정수 값이어야
    하고 상위 `postergrid` 환경의 행의 개수보다 작거나 같아야 합니다. 또 첫 번째
    값이 두 번째 값보다 작거나 같아야 합니다.

- `col`

  열의 위치입니다. 2가지 유형의 값이 가능합니다.

  - `<c>` 유형

    양의 정수 하나로 위치를 나타내는 방법입니다. 양의 정수 값이어야 하고 상위
    `postergrid` 환경의 열의 개수보다 작거나 같아야 합니다.

  - `<c1>-<c2>` 유형

    양의 정수 두 개로 위치를 나타내는 방법입니다. 각 값은 양의 정수 값이어야
    하고 상위 `postergrid` 환경의 열의 개수보다 작거나 같아야 합니다. 또 첫 번째
    값이 두 번째 값보다 작거나 같아야 합니다.

- `options`

  - `color`

    블록 색입니다. `xcolor` 패키지 색 이름이어야 합니다. 기본값은 가장 가까운
    상위 환경의 `block-color` 값입니다.

  - `corner-radius`

    블록 모서리 반지름입니다. 음이 아닌 길이 값이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `block-corner-radius` 값입니다.

  - `margin`

    블록 내부 여백 너비입니다. 음이 아닌 길이 값이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `block-margin` 값입니다.

  - `align`

    블록 내부 본문의 수직 정렬입니다. `top`, `center`, `bottom` 중 하나여야
    합니다. 기본값은 가장 가까운 상위 환경의 `block-align` 값입니다.

  - `column-count`

    블록 내부 본문 열의 개수입니다. 양의 정수 값이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `block-column-count` 값입니다.

  - `column-sep`

    블록 내부 본문 열 사이 간격입니다. 음이 아닌 길이 값이어야 합니다. 기본값은
    가장 가까운 상위 환경의 `block-column-sep` 값입니다.

  - `leading`

    블록 내부 본문 줄의 글자 영역 사이 간격입니다. 음이 아닌 길이 값이어야
    합니다. 기본값은 가장 가까운 상위 환경의 `block-leading` 값입니다.

  - `paragraph-sep`

    블록 내부 단락 사이 간격입니다. 음이 아닌 길이 값이어야 합니다. 기본값은
    가장 가까운 상위 환경의 `block-paragraph-sep` 값입니다.

  - `paragraph-indent`

    블록 내부 단락 들여쓰기 너비입니다. 음이 아닌 길이 값이어야 합니다. 기본값은
    가장 가까운 상위 환경의 `block-paragraph-indent` 값입니다.

  - `blocktitle-size`

    블록 제목 크기입니다. 양의 길이 값이어야 합니다. 기본값은 가장 가까운 상위
    환경의 `blocktitle-size` 값입니다.

  - `blocktitle-color`

    블록 제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다. 기본값은 가장
    가까운 상위 환경의 `blocktitle-color` 값입니다.

  - `sectiontitle-size`

    절 제목 크기입니다. 양의 길이 값이어야 합니다. 기본값은 가장 가까운 상위
    환경의 `sectiontitle-size` 값입니다.

  - `sectiontitle-color`

    절 제목 색입니다. `xcolor` 패키지 색 이름이어야 합니다. 기본값은 가장 가까운
    상위 환경의 `sectiontitle-color` 값입니다.

  - `text-size`

    본문 크기입니다. 양의 길이 값이어야 합니다. 기본값은 가장 가까운 상위 환경의
    `text-size` 값입니다.

  - `text-color`

    본문 색입니다. `xcolor` 패키지 색 이름이어야 합니다. 기본값은 가장 가까운
    상위 환경의 `text-color` 값입니다.

##### `posterblock*`

가상의 블록 환경입니다. 블록에 의한 여백 없이 영역을 격자로 나눌 때 사용할 수
있습니다.

`posterblock*` 환경은 `postergrid` 환경 내에서 정의될 수 있습니다. `postergrid`
환경 내 `posterblock` 환경과 `posterblock*` 환경끼리는 차지하는 영역이 겹치지
않아야 합니다. `posterblock*` 환경 내에는 `postergrid` 환경만 최대 하나 직접
들어갈 수 있습니다.

```latex
\begin{posterblock*}{<row>}{<col>}
  ...
\end{posterblock*}
```

- `row`

  행의 위치입니다. 2가지 유형의 값이 가능합니다.

  - `<r>` 유형

    양의 정수 하나로 위치를 나타내는 방법입니다. 양의 정수 값이어야 하고 상위
    `postergrid` 환경의 행의 개수보다 작거나 같아야 합니다.

  - `<r1>-<r2>` 유형

    양의 정수 두 개로 위치를 나타내는 방법입니다. 각 값은 양의 정수 값이어야
    하고 상위 `postergrid` 환경의 행의 개수보다 작거나 같아야 합니다. 또 첫 번째
    값이 두 번째 값보다 작거나 같아야 합니다.

- `col`

  열의 위치입니다. 2가지 유형의 값이 가능합니다.

  - `<c>` 유형

    양의 정수 하나로 위치를 나타내는 방법입니다. 양의 정수 값이어야 하고 상위
    `postergrid` 환경의 열의 개수보다 작거나 같아야 합니다.

  - `<c1>-<c2>` 유형

    양의 정수 두 개로 위치를 나타내는 방법입니다. 각 값은 양의 정수 값이어야
    하고 상위 `postergrid` 환경의 열의 개수보다 작거나 같아야 합니다. 또 첫 번째
    값이 두 번째 값보다 작거나 같아야 합니다.

##### `document`

문서 환경으로, `ropas-poster` 클래스에서는 최상위 블록을 담당합니다. 내부에
본문이나 격자를 가질 수 있습니다.

`document` 환경 내부로는 다음 2가지 유형이 가능합니다.

- 본문 유형

  본문 내용이 들어간 유형입니다. 블록 제목은 최대 하나 있을 수 있으며, 절
  제목에는 제한이 없습니다.

- 격자 유형

  `postergrid` 환경이 들어간 유형입니다. 블록 제목은 최대 하나 있을 수 있으며,
  절 제목이나 다른 내용은 들어갈 수 없습니다.

`document` 환경은 마치 `posterblock` 환경처럼 작동하지만 실제로 직사각형 블록을
생성하지는 않습니다.

#### 본문 환경

본문에서 사용할 수 있는 환경입니다. `article`, `acmart` 클래스에서 지원하는
환경과 비슷합니다.

##### `description`

항목마다 이름을 붙여 나열하는 목록 환경입니다. 항목 이름은 굵은 정자체로
출력됩니다.

```latex
\begin{description}
  ...
\end{description}
```

목록의 각 항목은 `\item[<name>]`으로 시작합니다. `name`은 항목의 이름이며
생략하면 이름 없이 항목이 출력됩니다.

##### `verse`

시나 가사처럼 줄바꿈이 중요한 내용을 출력하는 환경입니다. 한 줄이 너무 길어서
여러 줄로 출력되면 두 번째 줄부터 들여써집니다.

```latex
\begin{verse}
  ...
\end{verse}
```

줄은 `\\[<length>]`나 `\\*[<length>]`로 나눌 수 있습니다. 첫 번째는 그냥 줄을
나누고 두 번째는 줄을 나누되 해당 지점에서 열이 바뀌는 것을 막습니다. `length`는
줄 사이의 간격이며 올바른 TeX 길이여야 합니다.

##### `quotation`

여러 단락으로 된 인용문을 출력하는 환경입니다. 인용문 전체를 본문보다 안쪽에
배치하고 일반적인 본문 들여쓰기를 사용합니다.

```latex
\begin{quotation}
  ...
\end{quotation}
```

##### `quote`

짧은 인용문을 출력하는 환경입니다. 인용문 전체를 본문보다 안쪽에 배치하지만
`quotation` 환경과는 달리 각 단락의 첫 줄을 들여쓰지 않습니다.

```latex
\begin{quote}
  ...
\end{quote}
```

##### `figure`

그림과 해설문을 묶는 환경입니다. 본문 열 하나 너비로 떠다닙니다.

```latex
\begin{figure}[<placement>]
  ...
\end{figure}
```

- `placement`

  환경의 가능한 위치를 나타내는 깃발입니다. 다음 값의 조합이 가능합니다.
  기본값은 `tb`입니다.

  - `h`: 환경이 정의된 위치를 나타냅니다. `h`만 두면 클래스에서 자동으로 `ht`로
    바꾸고 경고를 출력합니다.
  - `t`: 열 위쪽을 나타냅니다.
  - `b`: 열 아래쪽을 나타냅니다.
  - `!`: 혼자 쓰이지 않으며 배치에 대한 제한을 완화합니다.
  - `H`: 다른 값과 조합되지 않고 혼자 쓰이며, 떠다니지 않고 환경을 정의된 위치에
    출력합니다.

해설문은 `\caption{<caption>}`(번호가 있는 해설문)이나
`\caption*{<caption>}`(번호가 없는 해설문)으로 추가할 수 있습니다. 여기서
`caption`은 그림의 해설문입니다.

##### `figure*`

그림과 해설문을 묶는 환경입니다. 블록의 내용 영역 너비로 떠다닙니다.

```latex
\begin{figure*}[<placement>]
  ...
\end{figure*}
```

- `placement`

  환경의 가능한 위치를 나타내는 깃발입니다. 다음 값의 조합이 가능합니다.
  기본값은 `tb`입니다.

  - `h`: 환경이 정의된 위치를 나타냅니다. `h`만 두면 클래스에서 자동으로 `ht`로
    바꾸고 경고를 출력합니다.
  - `t`: 블록 위쪽을 나타냅니다.
  - `b`: 블록 아래쪽을 나타냅니다.
  - `!`: 혼자 쓰이지 않으며 배치에 대한 제한을 완화합니다.
  - `H`: 다른 값과 조합되지 않고 혼자 쓰이며, 떠다니지 않고 환경을 정의된 위치에
    출력합니다.

해설문은 `figure` 환경에서와 같은 방법으로 추가할 수 있습니다.

##### `table`

표와 해설문을 묶는 환경입니다. 본문 열 하나 너비로 떠다닙니다.

```latex
\begin{table}[<placement>]
  ...
\end{table}
```

- `placement`

  환경의 가능한 위치를 나타내는 깃발입니다. 가능한 값은 `figure` 환경과
  같습니다. 기본값은 `tb`입니다.

해설문은 `figure` 환경에서와 같은 방법으로 추가할 수 있습니다.

##### `table*`

표와 해설문을 묶는 환경입니다. 블록의 내용 영역 너비로 떠다닙니다.

```latex
\begin{table*}[<placement>]
  ...
\end{table*}
```

- `placement`

  환경의 가능한 위치를 나타내는 깃발입니다. 가능한 값은 `figure*` 환경과
  같습니다. 기본값은 `tb`입니다.

해설문은 `figure` 환경에서와 같은 방법으로 추가할 수 있습니다.

##### `theorem`

정리를 위한 정리 환경입니다. `acmplain` 형식을 사용합니다.

```latex
\begin{theorem}[<info>]
  ...
\end{theorem}
```

- `info`

  정리에 대한 부가 정보입니다.

##### `conjecture`

추측을 위한 정리 환경입니다. `acmplain` 형식을 사용합니다.

```latex
\begin{conjecture}[<info>]
  ...
\end{conjecture}
```

- `info`

  추측에 대한 부가 정보입니다.

##### `proposition`

명제를 위한 정리 환경입니다. `acmplain` 형식을 사용합니다.

```latex
\begin{proposition}[<info>]
  ...
\end{proposition}
```

- `info`

  명제에 대한 부가 정보입니다.

##### `lemma`

도움정리를 위한 정리 환경입니다. `acmplain` 형식을 사용합니다.

```latex
\begin{lemma}[<info>]
  ...
\end{lemma}
```

- `info`

  도움정리에 대한 부가 정보입니다.

##### `corollary`

따름정리를 위한 정리 환경입니다. `acmplain` 형식을 사용합니다.

```latex
\begin{corollary}[<info>]
  ...
\end{corollary}
```

- `info`

  따름정리에 대한 부가 정보입니다.

##### `example`

예시를 위한 정리 환경입니다. `acmdefinition` 형식을 사용합니다.

```latex
\begin{example}[<info>]
  ...
\end{example}
```

- `info`

  예시에 대한 부가 정보입니다.

##### `definition`

정의를 위한 정리 환경입니다. `acmdefinition` 형식을 사용합니다.

```latex
\begin{definition}[<info>]
  ...
\end{definition}
```

- `info`

  정의에 대한 부가 정보입니다.

### 기타
#### `amsthm` 패키지

`ropas-poster` 클래스에서는 다음 정리 형식을 추가로 제공합니다. 각 형식은
`text-size`에 비례해 정의됩니다.

아래 형식을 `\newtheoremstyle` 명령어로 재정의하는 것은 권장하지 않습니다.
재정의하더라도 클래스에서 오류를 출력하지는 않지만 출력 결과가 올바르지 않을
수도 있습니다.

- ACM 형식

  실제 `acmart` 클래스의 정의와는 달리, 번호가 포스터 전체에서 이어집니다.

  - `acmplain`
  - `acmdefinition`

#### `xcolor` 패키지

`ropas-poster` 클래스에서는 다음 `xcolor` 색을 추가로 제공합니다.

- 서울대학교 색

  - `SNUBlue`: cmyk (1, 0.85, 0, 0.15)
  - `SNUBeige`: cmyk (0.13, 0.1, 0.25, 0)
  - `SNUGray`: cmyk (0, 0, 0, 0.6)

- ACM 색

  - `ACMBlue`: cmyk (1, 0.1, 0, 0.1)
  - `ACMYellow`: cmyk (0, 0.16, 1, 0)
  - `ACMOrange`: cmyk (0, 0.42, 1, 0.01)
  - `ACMRed`: cmyk (0, 0.9, 0.86, 0)
  - `ACMLightBlue`: cmyk (0.49, 0.01, 0, 0)
  - `ACMGreen`: cmyk (0.2, 0, 1, 0.19)
  - `ACMPurple`: cmyk (0.55, 1, 0, 0.15)
  - `ACMDarkBlue`: cmyk (1, 0.58, 0, 0.21)

- 테마에 사용되는 색

  - `theme-default-bg`: HTML `194598`
  - `theme-default-text`: HTML `515151`
