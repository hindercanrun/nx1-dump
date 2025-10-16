//****************************************************************************
//                                                                          **
//           Confidential - (C) Activision Publishing, Inc. 2010            **
//                                                                          **
//****************************************************************************
//                                                                          **
//    Module:  The script grabs all the grapple_objective and put them into **
//             a level array.                                               **
//             1 script origin:                                             **
//                   script origin: "targetname" "grapple_objective"        **
//                                                                          **
//    Created: June 29th, 2011 - James Chen                                 **
//                                                                          **
//***************************************************************************/

main()
{
	level._GrappleObjective = getentArray_and_assert ( "grapple_objective" );
}

//*******************************************************************
//                                                                  *
//                                                                  *
//*******************************************************************
//tagJC<NOTE>: Useful helper function to get the requested entity and check for any errors
getentArray_and_assert( ent_name )
{
	object = getEntArray( ent_name, "targetname" );
	AssertEX( object.size > 0 , "There is no entity for " + ent_name );
	return object;
} 
