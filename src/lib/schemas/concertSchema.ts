import { z } from 'zod';

export const concertFormSchema = z.object({
	artist: z.string().min(1, 'Artist is required').max(200),
	concertName: z.string().max(200).optional().default(''),
	date: z.string().min(1, 'Date is required'),
	imageUrl: z.string().url('Invalid URL').min(1, 'Image URL is required'),
	description: z.string().max(2000).optional().default(''),
	venueId: z.string().min(1, 'Please select a valid venue')
});

export type ConcertFormSchema = typeof concertFormSchema;
