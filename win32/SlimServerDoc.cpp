// SlimServerDoc.cpp : implementation of the CSlimServerDoc class


#include "stdafx.h"
#include "SlimServer.h"
#include "SlimServerDoc.h"



#ifdef _DEBUG
#define new DEBUG_NEW
#endif

// CSlimServerDoc

IMPLEMENT_DYNCREATE(CSlimServerDoc, CDocument)

BEGIN_MESSAGE_MAP(CSlimServerDoc, CDocument)
END_MESSAGE_MAP()

// CSlimServerDoc construction/destruction
CSlimServerDoc::CSlimServerDoc()

{
	// TODO: add one-time construction code here
}



CSlimServerDoc::~CSlimServerDoc()

{

}



BOOL CSlimServerDoc::OnNewDocument()

{

	if (!CDocument::OnNewDocument())

		return FALSE;



	// I am starting up the slim server here

	// will disable all new document sections so this will only get called once 

	

	

	



	return TRUE;

}









// CSlimServerDoc serialization



void CSlimServerDoc::Serialize(CArchive& ar)

{

	if (ar.IsStoring())

	{

		// TODO: add storing code here

	}

	else

	{

		// TODO: add loading code here

	}

}





// CSlimServerDoc diagnostics



#ifdef _DEBUG

void CSlimServerDoc::AssertValid() const

{

	CDocument::AssertValid();

}



void CSlimServerDoc::Dump(CDumpContext& dc) const

{

	CDocument::Dump(dc);

}

#endif //_DEBUG





// CSlimServerDoc commands

