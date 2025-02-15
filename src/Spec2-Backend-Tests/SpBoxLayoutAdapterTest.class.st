Class {
	#name : #SpBoxLayoutAdapterTest,
	#superclass : #SpLayoutAdapterTest,
	#category : #'Spec2-Backend-Tests-Layout'
}

{ #category : #testing }
SpBoxLayoutAdapterTest class >> isAbstract [

	^ self == SpBoxLayoutAdapterTest
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testAdapterElementsAreInSameOrderThanLayout [

	| first second |
	layout add: (first := SpButtonPresenter new).
	layout add: (second := SpButtonPresenter new).
	self assert: self adapter children first equals: first adapter widget.
	self assert: self adapter children second equals: second adapter widget.
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testAddElementAddsToAdapter [

	layout add: SpButtonPresenter new.
	self deny: self adapter isEmpty
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testAddElementAfterOpenAddsToAdapter [

	layout add: SpButtonPresenter new.
	self openInstance.
	
	layout add: SpButtonPresenter new.
	self assert: self adapter children size equals: 2
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testLayoutCanHaveMoreThanTwoChildren [

	layout add: SpButtonPresenter new.
	layout add: SpButtonPresenter new.
	layout add: SpButtonPresenter new.
	
	self assert: layout children size equals: 3
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testRemoveElementAddedAfterOpenRemovesFromAdapter [

	| element |
	layout add: (element := SpButtonPresenter new).
	self openInstance.
	
	layout remove: element.
	self assert: self adapter isEmpty
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testRemoveElementRemovesFromAdapter [

	| element |
	layout add: (element := SpButtonPresenter new).
	layout remove: element.
	self assert: self adapter isEmpty
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testReplaceElementAfterOpen [
	| p1 toReplace p2 replacement |
	
	layout add: (p1 := SpLabelPresenter new).
	layout add: (toReplace := SpLabelPresenter new).
	layout add: (p2 := SpLabelPresenter new).
	self openInstance.
	
	replacement := SpButtonPresenter new.
	layout replace: toReplace with: replacement.
	
	self assert: self adapter children size equals: 3.
	self 
		assert: self adapter children 
		equals: { 
			p1 adapter widget. 
			replacement adapter widget. 
			p2 adapter widget }
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testReplaceElementAppliesStyle [
	| p1 toReplace p2 replacement |
	
	layout add: (p1 := SpLabelPresenter new).
	layout add: (toReplace := SpLabelPresenter new).
	layout add: (p2 := SpLabelPresenter new).
	self openInstance.
	
	replacement := SpLabelPresenter new.
	replacement addStyle: 'code'. "code assigns code fonts"
	layout replace: toReplace with: replacement.
	
	self assert: self adapter children size equals: 3.
	self 
		assert: replacement adapter widget font
		equals: StandardFonts codeFont
]

{ #category : #tests }
SpBoxLayoutAdapterTest >> testReplaceElementBeforeOpenAppliesStyle [
	| p1 toReplace p2 replacement |
	
	layout add: (p1 := SpLabelPresenter new).
	layout add: (toReplace := SpLabelPresenter new).
	layout add: (p2 := SpLabelPresenter new).
	
	replacement := SpLabelPresenter new.
	replacement addStyle: 'code'. "code assigns code fonts"
	layout replace: toReplace with: replacement.

	self openInstance.
	
	self assert: self adapter children size equals: 3.
	self 
		assert: replacement adapter widget font
		equals: StandardFonts codeFont
]
