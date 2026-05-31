<?php

namespace App\Console\Commands;

use App\Models\UrlImportJob;
use App\Services\GeoAmplify\UrlImportProcessingService;
use Illuminate\Console\Command;

class GeoAmplifyProcessUrlImportCommand extends Command
{
    protected $signature = 'geoamplify:process-url-import {jobId : URL import job ID}';

    protected $description = 'Process a GEOAmplify URL smart import job in the background';

    public function handle(UrlImportProcessingService $service): int
    {
        $job = UrlImportJob::query()->whereKey((int) $this->argument('jobId'))->first();
        if (! $job) {
            $this->error('URL import job not found.');

            return self::FAILURE;
        }

        if (in_array($job->status, ['completed', 'imported'], true)) {
            $this->info('URL import job already completed.');

            return self::SUCCESS;
        }

        $service->process($job);
        $this->info('URL import job processed.');

        return self::SUCCESS;
    }
}
