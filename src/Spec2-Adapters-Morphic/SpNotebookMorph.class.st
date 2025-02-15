"
I'm a tab morph used to build spec notebooks.
I extend my parent by adding special ways to add pages (allowing any widget to be a page).
I also add a toolbar to add actions.
"
Class {
	#name : #SpNotebookMorph,
	#superclass : #TabGroupMorph,
	#instVars : [
		'headerMorph',
		'toolbarMorph'
	],
	#category : #'Spec2-Adapters-Morphic-Notebook'
}

{ #category : #accessing }
SpNotebookMorph class >> tabCellInset [

	^ 2
]

{ #category : #adding }
SpNotebookMorph >> addLazyPage: aBlock label: aStringOrMorph model: aSpNotebookPage [ 
	| newPage label |
	
	newPage := SpNotebookPageMorph new.
	newPage lazyPageMorphCreation: aBlock.

	"not adding actions here, for our notebook it will be 
	coded in the label widget (since I may want to control when close, etc.)"
	label := self 
		buildLabelFrom: aStringOrMorph 
		withAction: nil. 
	
	newPage labelMorph: label.
	
	self addPage: newPage label: label
]

{ #category : #adding }
SpNotebookMorph >> addPage: aMorph label: aStringOrMorph [
	
	super addPage: aMorph label: aStringOrMorph.
	aMorph privateOwner: self
]

{ #category : #private }
SpNotebookMorph >> buildLabelFrom: aString [ 
	
	^ LabelMorph newLabel: aString
]

{ #category : #private }
SpNotebookMorph >> buildLabelFrom: aStringOrMorph withAction: aMorph [
	| innerLabel |

	innerLabel := aStringOrMorph isMorph
		ifTrue: [ aStringOrMorph ]
		ifFalse: [ self buildLabelFrom: aStringOrMorph ].
	
	aMorph ifNotNil: [
		innerLabel addMorphBack: aMorph ].

	^ innerLabel
]

{ #category : #testing }
SpNotebookMorph >> hasPageWithModel: anObject [
	"an utility to easy know if the notebook has a page for a model"

	^ self pages anySatisfy: [ :each | each model = anObject ]
]

{ #category : #accessing }
SpNotebookMorph >> headerMorph [
	^ headerMorph
]

{ #category : #accessing }
SpNotebookMorph >> headerMorph: anObject [
	headerMorph := anObject.
	
	headerMorph clipSubmorphs: true.
]

{ #category : #initialization }
SpNotebookMorph >> initialize [

	super initialize.
	self 
		removeMorph: self contentMorph;
		removeMorph: self tabSelectorMorph;  
		headerMorph: self newHeaderMorph;
		addMorph: self headerMorph;
		addMorph: self contentMorph
]

{ #category : #factory }
SpNotebookMorph >> newCloseButtonFor: aSpNotebookPage [

	^ self theme
		newCloseControlIn: self
		for: aSpNotebookPage
		action: [ aSpNotebookPage removeFromNotebook ]
		help: 'Close this page' translated
]

{ #category : #factory }
SpNotebookMorph >> newContentMorph [
	"Answer a new content morph"

	^ PanelMorph new
		roundedCorners: #(2 3 4);
		changeTableLayout; 
		layoutInset: 4;
		cellInset: 8;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		borderStyle: (self theme tabPanelBorderStyleFor: self);
		yourself
]

{ #category : #private }
SpNotebookMorph >> newHeaderMorph [

	^ (self theme newRowIn: self theme for: { self tabSelectorMorph }) 
		cellInset: 0; 
		cellPositioning: #bottomCenter; 
		borderWidth: 0
]

{ #category : #factory }
SpNotebookMorph >> newTabSelectorMorph [ 

	^ SpNotebookTabSelectorMorph new
		vResizing: #shrinkWrap;
		hResizing: #spaceFill;
		cellInset: self class tabCellInset;
		yourself
]

{ #category : #private }
SpNotebookMorph >> pageAt: index [

	^ (self pages at: index) actualPageMorph
]

{ #category : #accessing }
SpNotebookMorph >> pageWithModel: anObject [
	"an utility to easy find pages with a model"

	^ self pages detect: [ :each | each model = anObject ]
]

{ #category : #private }
SpNotebookMorph >> postAddPage: aMorph [ 
	"a hook to format the page after creation"
]

{ #category : #private }
SpNotebookMorph >> removePage: aPage [
	| removedPageIndex |
	
	removedPageIndex := self pages indexOf: aPage.

	self suspendAnnouncementsDuring: [ 
		self pages remove: aPage.
		self tabSelectorMorph removeTabIndex: removedPageIndex ].

	self announcer announce: (SpNotebookPageRemoved new
			tabs: self;
			page: aPage;
			pageIndex: removedPageIndex;
			newIndex: self tabSelectorMorph selectedIndex).

	self pages ifEmpty: [ self contentMorph removeAllMorphs ]
]

{ #category : #private }
SpNotebookMorph >> removePageIndex: anInteger [
	self removePage: (self pages at: anInteger)
]

{ #category : #private }
SpNotebookMorph >> suspendAnnouncementsDuring: aBlock [
	| subscriptions |
	subscriptions := self announcer subscriptions subscriptions.
	subscriptions do: [ :sub | self announcer unsubscribe: sub ].
	aBlock value.
	subscriptions do: [ :sub | self announcer basicSubscribe: sub ]
]

{ #category : #private }
SpNotebookMorph >> updateContentMorph: aMorph with: newMorph [
	| pageBounds |

	pageBounds := self pageMorph bounds.
	self contentMorph replaceSubmorph: aMorph by: newMorph.
	self flag: 'Without setting here the bounds the page moves a few pixels when 
	refreshing the inspector'.
	self pageMorph bounds: pageBounds.
	self pageMorph layoutChanged
]

{ #category : #private }
SpNotebookMorph >> updatePageIndex: index [
	"Change to the given page index, update the toolbar and send the announcement"
	| oldPage newPage |

	index = 0 ifTrue: [ ^ self ].

	oldPage := self pages at: self selectedPageIndex.
	self pageMorph
		ifNotNil: [ :aPage | self updateContentMorph: aPage with: (self pageAt: index) ]
		ifNil: [ self contentMorph addMorph: (self pageAt: index) ].

	newPage := self pages at: index.
	self postAddPage: newPage.

	self headerMorph layoutChanged.
	self pageMorph layoutChanged.
	self adoptPaneColor: (self owner ifNil: [ self ]) paneColor.
	self tabSelectorMorph font ifNotNil: [ :aFont |
		(self tabSelectorMorph tabs at: index) font: aFont ].

	self announcer announce: (SpNotebookPageChanged new
		page: newPage;
		oldPage: oldPage;
		pageIndex: index)
]

{ #category : #private }
SpNotebookMorph >> updatePageIndex: index oldIndex: oldSelectedIndex [
	"Change to the given page index, update the toolbar and send the announcement"
	| oldPage newPage |

	index = 0 ifTrue: [ ^ self ].

	oldPage := self pages at: oldSelectedIndex.
	self pageMorph
		ifNotNil: [ :aPage | self updateContentMorph: aPage with: (self pageAt: index) ]
		ifNil: [ self contentMorph addMorph: (self pageAt: index) ].

	newPage := self pages at: index.
	self postAddPage: newPage.
	self headerMorph layoutChanged.
	self pageMorph layoutChanged.
	self adoptPaneColor: (self owner ifNil: [ self ]) paneColor.
	self tabSelectorMorph font ifNotNil: [ :aFont | 
		(self tabSelectorMorph tabs at: index) font: aFont ].
	
	self announcer announce: (SpNotebookPageChanged new
		page: newPage;
		oldPage: oldPage;
		pageIndex: index)
]
